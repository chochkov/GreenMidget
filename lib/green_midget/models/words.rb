# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  class Words < Countable
    PREFIX = 'word::'

    def self.prefix; PREFIX end

    # Pr(word | category)
    def probability_for(category)
      self[category] / Examples.general[category]
    end

    def self.record_keys(words, category = nil)
      categories = [ category || GreenMidget::CATEGORIES ].flatten
      words.map do |word|
        categories.map{ |category| Words[word].record_key(category) }
      end.flatten
    end
  end
end
