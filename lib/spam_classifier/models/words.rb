# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module SpamClassifier
  class Words < Countable
    PREFIX = 'word::'

    def self.prefix; PREFIX end

    # Pr(word | category)
    def probability_for(category)
      self[category] / Examples.general[category]
    end
  end
end
