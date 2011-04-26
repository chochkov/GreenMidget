class Features < SpamClassificationIndex
  def self.[](feature)
    unless SpamClassifier::FEATURES.include?(feature)
      raise ArgumentError.new("Nonexistent feature given as an argument: #{feature.inspect}")
    end

    super("with_feature::#{feature}")
  end

  # Pr(feature | category)
  def probability_for(category)
    self[category] / TrainingExamples[key][category]
  end

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
