# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
class SpamCheck < GreenMidget::Base
  attr_accessor :text

  def initialize(text)
    self.text = text
  end
end
