module SpamClassifier
  class Base
    include PublicMethods
    include Logger

    private

    # ------ Default Heuristics --------

    def pass_ham_heuristics?
      true
    end

    def pass_spam_heuristics?
      true
    end

    # ------ Features --------

    def features
      FEATURES
    end

    def present_features
      features.select { |feature| feature_present?(feature) }
    end

    def missing_features
      features - present_features
    end

    def feature_present?(feature)
      method = :"#{feature}?"
      if respond_to?(method, true)
        send(method)
      else
        raise NoMethodError.new("You must implement method #{method} or remove this feature: #{feature}.")
      end
    end

    def url_in_text?
      text.scan(URL_REGEX).size > 0
    end

    def email_in_text?
      text.scan(EMAIL_REGEX).size > 0
    end

    # ------ Words --------

    def words
      strip_external_links.scan(WORDS_SPLIT_REGEX).to_a.uniq.
        map(&:downcase).
        reject { |w| IGNORED_WORDS.include?(w) }
    end

    def known_words(category)
      words.reject { |word| Words[word][category] == 0.0 }
    end

    def new_words(category)
      words - known_words(category)
    end

    def strip_external_links
      text.gsub(EXTERNAL_LINK_REGEX, '')
    end

    # ------ Accessors --------

    def text
      @text || raise(NoMethodError.new('You should either implement the text method or provide an instance variable at this point.'))
    end

    # ------ Probabilities Calculation --------

    # We use the ratio between Spam Probability and Ham Probability as decision criterion.
    # We do individual word-occurrence analysis as well as SpamClassifier::FEATURES list of features
    # with words and features being naively considered independent:
    # - text analysis i.e. Pr(category | text) = Pr(category | word_1) * .. * Pr(category | word_N)
    # - features - eg. url found in text => Pr(category | url_in_text)
    def spam_ham_ratio
      # Pr(category = spam | text) / Pr(category = ham | text)
      spam_prob, ham_prob = category_probability(:spam), category_probability(:ham)
      return case
        when (ham_prob.eql?(0.0) && spam_prob > 0)
          SPAM_THRESHOLD / 1.0
        when (spam_prob.eql?(0.0) && ham_prob > 0)
          1.0/2.0
        when (spam_prob.eql?(0.0) && ham_prob.eql?(0.0))
          1.0
        else
          spam_prob / ham_prob
        end
    end

    # Pr(category | text, user)
    def category_probability(category)
      # Bayesean Theorem:
      # Pr(category | text, user) = Pr(word_1 | category) * ... * Pr(word_N | category) *
      # * Pr(feature_1 | category) * ... * Pr(feature_K | category) * Pr(category) / Pr(text, user)

      from_words    = words_probability_for(category)
      from_features = features_probability_for(category)

      if from_words.eql?(1.0) && from_features.eql?(1.0)
        0.0
      else
        from_words * from_features * TrainingExamples.probability_for(category) / text_and_user_probability
      end
    end

    # Pr(words | category) = Pr(word_1 | category) * ... * Pr(word_N | category)
    def words_probability_for(category)
      if known_words(category).count == 0
        return 0.0
      end

      probability = known_words(category).inject(1.0) do |memo, word|
        memo * Words[word].probability_for(category)
      end

      if new_words(category).count > 0
        probability *= (1.0 / TrainingExamples.total_count) ** new_words(category).count
      else
        probability
      end
    end

    # Pr(features | category) = Pr(feature_1 | category) * .. * Pr(feature_K | category)
    def features_probability_for(category)
      features.inject(1.0) do |memo, feature|
        memo * Features[feature].probability_for(category)
      end
    end

    # Pr(text)
    def text_and_user_probability
      # We don't need to calculate this, because Pr(text) would cancel out in the spam_ham_ratio.
      # This method should implement the probability calculation if necessary.
      return 1.0
    end
  end
end
