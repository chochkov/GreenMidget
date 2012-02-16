# A mixin that implements features check and allows Base sublcasses
# to define their own features for spam/ham detection.
#
# By default texts are checked for presence of external URL or email
# references. An example of addional feature would be presence of particular
# words or expressions.
#
# See the example in `lib/green_midget/extensions/sample.rb`
#
module GreenMidget
  module DefaultFeatures

    private

    def features
      FEATURES
    end

    def present_features
      features.select { |feature| feature_present?(feature) }
    end

    def feature_present?(feature)
      method = :"#{feature}?"
      if respond_to?(method, true)
        send(method)
      else
        raise FeatureMethodNotImplemented.new(feature, method)
      end
    end

    def url_in_text?
      UrlDetection.new(text).any?
    end

    def email_in_text?
      text.scan(EMAIL_REGEX).size > 0
    end
  end
end
