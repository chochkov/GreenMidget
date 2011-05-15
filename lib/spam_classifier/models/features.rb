# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module SpamClassifier
  class Features < Countable
    PREFIX = 'feature::'

    def self.prefix; PREFIX end

    # Pr(feature | category)
    def probability_for(category)
      self[category] / Examples[feature][category]
    end

    def feature
      key.gsub(/(^#{ PREFIX })|(::\w+_count$)/, '')
    end
  end
end
