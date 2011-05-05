class SpamCheck < SpamClassifier::Base
  attr_accessor :text

  def initialize(text)
    self.text = text
  end
end
