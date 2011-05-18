# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  class Words < Countable
    PREFIX = 'word::'

    def self.prefix; PREFIX end

    # Pr(word | category)
    def probability_for(category)
      count = self[category]
      if count == 0.0
        @@smoother ||= (1.0 / Examples.general.total_count)
      else
        count / Examples.general[category]
      end
    end

    def log_ratio
      Math::log(probability_for(CATEGORIES.last) / probability_for(CATEGORIES.first))
    end

    def self.record_keys(words, category = nil)
      categories = [ category || GreenMidget::CATEGORIES ].flatten
      words.map do |word|
        categories.map{ |category| Words[word].record_key(category) }
      end.flatten
    end
  end
end
