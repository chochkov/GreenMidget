module GreenMidget
  class FeatureMethodNotImplemented < StandardError
    def initialize(feature, method_name)
      super <<-MSG
Method #{method_name.inspect} not found. Either implement it or
delete feature #{feature} from your features list.
MSG
    end
  end
end

