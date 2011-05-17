# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
%w(logger constants url_detection).each do |file|
  require File.join(File.dirname(__FILE__), file)
end

module GreenMidget
  class Base
    include Logger
    include Constants

    def classify
      CATEGORIES.each do |category|
        if respond_to?(:"pass_#{category}_heuristics?") && send(:"pass_#{category}_heuristics?")
          classify_as!(category)
          return HYPOTHESES[category]
        end
      end

      GreenMidgetRecords.fetch_all(words)
      register_classification

      factor = bayesian_factor
      case
      when factor >= ACCEPT_ALTERNATIVE_MIN
        ALTERNATIVE
      when factor >= REJECT_ALTERNATIVE_MAX
        DUNNO
      else
        NULL
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
      register_training
    end

    private

    # ------ Features --------

    def features
      FEATURES
    end

    def present_features
      features.select { |feature| feature_present?(feature) }
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
        reject { |word| STOP_WORDS.include?(word) }
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

    # log [Pr(category = alternative | text) / Pr(category = null | text)]
    def bayesian_factor
      log_probability_null, log_probability_alternative = CATEGORIES.map { |category| log_probability(category) }
      case
        when (log_probability_null.eql?(0.0) && log_probability_alternative < 0.0)
          ACCEPT_ALTERNATIVE_MIN + 1.0
        when (log_probability_alternative.eql?(0.0) && log_probability_null < 0.0)
          REJECT_ALTERNATIVE_MAX - 1.0
        when (log_probability_alternative + log_probability_null == 0)
          (REJECT_ALTERNATIVE_MAX + ACCEPT_ALTERNATIVE_MIN) / 2.0
        else
          log_probability_alternative - log_probability_null
        end
    end

    def log_probability(category)
      if known_words(category).count.zero?
        0.0
      else
        log_probability_words(category) + log_probability_features(category) + Math::log(Examples.probability_for(category))
      end
    end

    def log_probability_words(category)
      probability = known_words(category).inject(0.0) do |memo, word|
        memo + Math::log(Words[word].probability_for(category))
      end
      probability += Math::log(1.0 / Examples.total_count) * new_words(category).count
    end

    def log_probability_features(category)
      present_features.inject(0.0) do |memo, feature|
        memo + Math::log(Features[feature].probability_for(category))
      end
    end
  end
end
