module SpamClassifier
  class Features < SpamClassificationIndex
    KEY_PREFIX = 'with_feature'
    
    def self.[](feature)
      super("#{KEY_PREFIX}::#{feature}")
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
      super.gsub(/^#{KEY_PREFIX}::/, '')
    end

    def self.fetch_all
      features = all(:conditions => "`key` LIKE #{KEY_PREFIX}::%'")
      features.inject({}) do |memo, feature|
        memo[feature.key] = feature
        memo
      end
    end
  end
end
