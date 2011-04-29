module SpamClassifier
  include Constants
  include PublicMethods

  private

  def log_classification
    yaml_dump = YAML::dump({
      :general => {
        :user_id              => @user.id,
        :text                 => words.join(' '),
        :spammable_class      => @spammable_class.to_s,
        :words_count          => words.count,
        :features_count       => features.count,
        :all_features_count   => FEATURES.count,
        :tested_on            => Time.now,
      },
      :spam => {
        :category_probability => category_probability(:spam),
        :from_words           => words_probability_for(:spam),
        :from_features        => features_probability_for(:spam),
        :known_words          => known_words(:spam).count,
        :spam_examples        => TrainingExamples.with_words[:spam],
      },
      :ham => {
        :category_probability => category_probability(:ham),
        :from_words           => words_probability_for(:ham),
        :from_features        => features_probability_for(:ham),
        :known_words          => known_words(:ham).count,
        :spam_examples        => TrainingExamples.with_words[:ham],
      }
    })
    Rails.logger.debug "=== SPAM CLASSIFICATION ==="
    Rails.logger.debug yaml_dump
    Rails.logger.debug "=== END ==="
  end

  def log_training

  end

  # ------ Default Heuristics --------

  def pass_ham_heuristics?
    if overwritten?(:pass_ham_heuristics?)
      spammable.pass_ham_heuristics?
    else
      true
    end
  end

  def pass_spam_heuristics?
    if overwritten?(:pass_ham_heuristics?)
      spammable.pass_ham_heuristics?
    else
      true
    end
  end

  # ------ Features --------

  def features
    (overwritten?(:features, Array) ? spammable.features : []) + FEATURES
  end

  def present_features
    features.select { |feature| feature_present?(feature) }
  end

  def missing_features
    features - present_features
  end

  def feature_present?(feature)
    method = :"#{feature}?"
    (overwritten?(method) ? spammable : self).send(method)
  end

  def url_in_text?
    UrlDetection.new(text).any?
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
    words.reject do |word|
      Words[word][category].eql?(0.0)
    end
  end

  def new_words(category)
    words - known_words(category)
  end

  def strip_external_links
    text.gsub(EXTERNAL_LINK_REGEX, '')
  end

  # ------ Accessors --------

  def text
    if overwritten?(:text)
      spammable.text
    elsif @text
      @text
    else
      raise ArgumentError.new("Either a @spammable (object) or @text (string) instance variable should be defined before classification. #{@text.inspect}, #{@spammable.inspect}")
    end
  end

  def spammable
    @spammable
  end

  def overwritten?(method, expected_class = nil)
    overwritten = spammable.respond_to?(method)

    if overwritten && expected_class
      spammable.send(method).is_a?(expected_class)
    else
      overwritten
    end
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
