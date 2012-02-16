# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
class Tester < GreenMidget::Base
  attr_accessor :text

  def initialize(text = '')
    @text = text
  end

  def words
    super
  end

  def log_ratio
    Records.fetch_all(words)
    super
  end
end
