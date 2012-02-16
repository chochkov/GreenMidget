# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  class Features < Countable
    self.prefix = 'feature::'

    def probability_for(category)
      self[category] / Examples[feature][category]
    end

    def feature
      key.gsub(/(^#{self.class.prefix})|(::\w+_count$)/, '')
    end
  end
end
