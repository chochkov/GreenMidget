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

      factor = log_ratio
      case
      when factor >= ACCEPT_ALTERNATIVE_MIN
        ALTERNATIVE_RESPONSE
      when factor >= REJECT_ALTERNATIVE_MAX
        DUNNO
      else
        NULL_RESPONSE
      end
    end

    def classify_as!(category)
      keys = [ Words.objects(words), Features.objects(present_features), Examples.objects(features, true) ].flatten.map do |object|
        object.record_key(category)
      end

      GreenMidgetRecords.increment(keys)
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
      method = :"#{ feature }?"
      if respond_to?(method, true)
        send(method)
      else
        raise("You must implement method #{ method } or remove feature #{ feature }.")
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

    def strip_external_links
      text.gsub(EXTERNAL_LINK_REGEX, '')
    end

    def text
      @text || raise('You should either implement the text method or provide an instance variable at this point.')
    end

    def log_ratio
      Examples.log_ratio + words.map{ |word| Words[word].log_ratio }.sum + present_features.map{ |feature| Features[feature].log_ratio }.sum
    end
  end
end
