module GreenMidget
  class NoTextFound < StandardError
    def initialize
      super <<-MSG
You should either implement the text method or provide an instance variable at this point.
MSG
    end
  end
end

