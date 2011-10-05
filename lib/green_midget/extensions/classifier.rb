# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  class Classifier < Base
    attr_accessor :text

    def initialize(text)
      self.text = text
    end
  end
end

