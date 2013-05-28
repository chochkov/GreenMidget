# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
#
# A model for Words used in GreenMidget. See Countable
#
module GreenMidget
  class Words < Countable
    self.prefix = 'word::'

    def self.record_keys(words, category = nil)
      words.map do |word|
        Array(category || CATEGORIES).map do |category|
          Words[word].record_key(category)
        end
      end.flatten
    end

    def probability_for(category)
      count = self[category]

      if count == 0.0
        1.0 / Examples.total
      else
        count / Examples.send(category)
      end
    end
  end
end
