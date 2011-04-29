module SpamClassifier
  class Features < SpamClassificationIndex
    def self.[](feature)
      #
      # TODO: consider dropping this restriction for dynamic features addition.
      # 
      # unless SpamClassifier.supported_features.include?(feature)
      #   raise ArgumentError.new("Unsupported feature given as an argument: #{feature.inspect}")
      # end
      # 
      super("with_feature::#{feature}")
    end

    # Pr(feature | category)
    def probability_for(category)
      self[category] / TrainingExamples[key][category]
    end

    # TODO: this method will be needed for including the negative probabilities.
    # # Pr(feature_not_existing | category) 1 - Pr(feature | category)
    # def negative_probability_for(category)
    #   1.0 - probability_for(category)
    # end

    def key
      super.gsub(/^feature::/, '')
    end

    def self.fetch_all
      features = all(:conditions => '`key` LIKE "feature::%"')
      features.inject({}) do |memo, feature|
        memo[feature.key] = feature
        memo
      end
    end
  end
end
