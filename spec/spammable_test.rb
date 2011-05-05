# This class is only used for testing in the spam_classifier_spec
#
class SpammableTest < SpamClassifier::Base
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
    SpammableTest.new(text)
  end

  def category_probability(category)
    cache
    super(category)
  end

  def spam_ham_ratio
    cache
    super
  end

  def pass_ham_heuristics?
    cache
    super
  end

  def words
    super
  end

  def new_words(category)
    super(category)
  end

  def known_words(category)
    super(category)
  end

  private

  def cache
    SpamClassifier::SpamClassificationIndex.fetch_all(words)
  end
end
