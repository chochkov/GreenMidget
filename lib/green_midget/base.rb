# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  class Base
    include DefaultFeatures
    include HeuristicChecks

    # Get classification for unknown messages based on history
    #
    #   Examples:
    #
    #   result = GreenMidget::Classifier.new(unknown_text)
    #   # result is now in -1, 0, 1 meaning respectively
    #   # no_spam, no_answer, spam
    #
    def classify
      if respond_to?(:heuristic_checks, true) && response = heuristic_checks
        return response
      end

      # load all relevant records in one go
      Records.fetch_all(words)

      factor = log_ratio
      case
      when factor >= ACCEPT_ALTERNATIVE_MIN
        RESPONSES[ALTERNATIVE]
      when factor >= REJECT_ALTERNATIVE_MAX
        RESPONSES[:dunno]
      else
        RESPONSES[NULL]
      end
    end

    # Public method used to train the classifier with examples
    # belonging to a known `category`.
    # 
    #   Examples:
    #
    #   classifier = GreenMidget::Classifier.new(known_good_text)
    #   classifier.classify_as!(:ham)
    #   # increases the chances for similar text to pass the check next time
    #
    #   classifier = GreenMidget::Classifier.new(known_spam_text)
    #   classifier.classify_as!(:spam)
    #   # increases the chances for similar text to fail the check next time
    #
    def classify_as!(category)
      keys = [
        Words.objects(words),
        Features.objects(present_features),
        Examples.objects(features, true)
      ].flatten.map { |object| object.record_key(category) }

      !! Records.increment(keys)
    end

    private

    def words
      strip_external_links.scan(WORDS_SPLIT_REGEX).uniq.
        map(&:downcase).
        reject { |word| STOP_WORDS.include?(word) }
    end

    def strip_external_links
      text.gsub(EXTERNAL_LINK_REGEX, '')
    end

    def text
      @text || raise(NoTextFound)
    end

    # Calculate the log ratio between the scores for both categories.
    # It takes into account the Examples counts ( ie. how much history
    # there is for each category ), the Words count ( i.e. how much history for
    # each word in each category ) and if any other Features are there -
    # accounts for them as well.
    def log_ratio
      result = Examples.log_ratio

      result += words.map{ |word| Words[word].log_ratio }.sum

      if respond_to?(:features, true)
        result += present_features.map{ |feature| Features[feature].log_ratio }.sum
      end

      result
    end
  end
end
