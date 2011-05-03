module SpamClassifier
  class Features < SpamClassificationIndex
    PREFIX = 'with_feature::'

    def self.[](feature)
      super(PREFIX + feature.to_s)
    end

    # Pr(feature | category)
    def probability_for(category)
      self[category] / TrainingExamples[key][category]
    end

    def key
      super.gsub(/^#{PREFIX}/, '')
    end

    def self.fetch_all
      features = all(:conditions => "`key` LIKE '#{ PREFIX }%'")
      features.inject({}) do |memo, feature|
        memo[feature.key] = feature
        memo
      end
    end
  end
end
