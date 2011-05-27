# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
class Tester < GreenMidget::Base
  attr_accessor :text

  ALPHABETIC_INDEX = ('a'..'z').to_a

  def initialize(text = '')
    self.text = text
  end

  def self.new_with_random_text(message_length=1, fixed_word_length = nil)
    message ||= []
    while message.count < message_length do
      word = ''
      (fixed_word_length || rand(7)+3).times { word += ALPHABETIC_INDEX[rand(26)] }
      message << word unless message.include?(word)
    end
    text = message.join(' ')
    Tester.new(text)
  end

  def words
    super
  end

  def log_ratio
    GreenMidgetRecords.fetch_all(words)
    super
  end
end
