module GreenMidget
  class NoExamplesGiven < StandardError
    def initialize
      super <<-MSG
Training examples must be provided for all categories before classification.
MSG
    end
  end
end
