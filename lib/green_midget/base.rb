# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
%w(logger constants url_detection).each do |file|
  require File.join(File.dirname(__FILE__), file)
end

module GreenMidget
  class Base
    include Logger
    include Constants

    def classify
      # check heuristics in the order
      CATEGORIES.each do |category|
        if respond_to?(:"pass_#{category}_heuristics?") && send(:"pass_#{category}_heuristics?")
          classify_as!(category)
          return "IS_#{category}".constantize
        end
      end

      GreenMidgetRecords.fetch_all(words)
      log_classification

      ratio = criterion_ratio
      case
      when ratio >= SPAM_THRESHOLD
        IS_SPAM
      when ratio >= 1.0
        DUNNO
      else
        IS_HAM
      end
    end

    def classify_as!(category)
      category = category.to_sym
      GreenMidgetRecords.fetch_all(words)

      keys = [ Words.many(words), Features.many(present_features), Examples.many_with_general(features) ].flatten.map do |object|
        object.record_key(category)
      end

      GreenMidgetRecords.increment(keys)
      GreenMidgetRecords.write!
      log_training
    end

    private

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
        raise NoMethodError.new("You must implement method #{method} or remove feature #{feature}.")
      end
    end

    def url_in_text?
      UrlDetection.new(text).any?
    end

    def email_in_text?
      text.scan(EMAIL_REGEX).size > 0
    end

    # ------ Words --------

    def words
      strip_external_links.scan(WORDS_SPLIT_REGEX).uniq.
        map(&:downcase).
        reject { |w| STOP_WORDS.include?(w) }
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

    # We use the ratio between Spam Probability and Ham Probability as decision criterion_ratio.
    # We do individual word-occurrence analysis as well as GreenMidget::FEATURES list of features
    # with words and features being naively considered independent:
    # - text analysis i.e. Pr(category | text) = Pr(category | word_1) * .. * Pr(category | word_N)
    # - features - eg. url found in text => Pr(category | url_in_text)
    def criterion_ratio
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

    # Pr(category | text)
    def category_probability(category)
      # Bayesean Theorem:
      # Pr(category | text) = Pr(word_1 | category) * ... * Pr(word_N | category) *
      # * Pr(feature_1 | category) * ... * Pr(feature_K | category) * Pr(category) / Pr(text)

      from_words    = words_probability_for(category)
      from_features = features_probability_for(category)

      if from_words.eql?(1.0) && from_features.eql?(1.0)
        0.0
      else
        from_words * from_features * Examples.probability_for(category) / text_and_user_probability
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
        probability *= (1.0 / Examples.total_count) ** new_words(category).count
      else
        probability
      end
    end

    # Pr(features | category) = Pr(feature_1 | category) * .. * Pr(feature_K | category)
    def features_probability_for(category)
      present_features.inject(1.0) do |memo, feature|
        memo * Features[feature].probability_for(category)
      end
    end

    # Pr(text)
    def text_and_user_probability
      # We don't need to calculate this, because Pr(text) would cancel out in the criterion_ratio.
      # This method should implement the probability calculation if necessary.
      return 1.0
    end
  end
end
