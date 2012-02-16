# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
#
# A model for Features used in GreenMidget. A Feature could be defined by user.
# An example would be 'url_found_in_text' which will be true for spammable
# objects that have url in their text and false otherwise.
#
#   Features['url_in_text'][:spam]
#   # the count of spam messages that have the feature
#
# See Countable
#
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
