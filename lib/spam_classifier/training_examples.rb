class TrainingExamples < SpamClassificationIndex

  def self.[](feature)
    unless SpamClassifier::FEATURES.include?(feature) || feature == 'words'
      raise ArgumentError.new("Nonexistent feature given as an argument: #{feature.inspect}")
    end

    examples         = super("training_examples_with_feature::#{feature}")
    examples_missing = (examples[:spam] * examples[:ham] == 0)

    if examples_missing && (feature == 'words')
      raise ZeroDivisionError.new('Training examples must be provided for both spam and ham messages before classification')
    elsif examples_missing
      self['words']
    else
      examples
    end
  end

  def self.with_words
    self['words']
  end

  # examples in category v.s. all examples
  def probability_for(category)
    self[category] / total_count
  end

  def self.probability_for(category)
    self['words'].probability_for(category)
  end

  def total_count
    self[:spam] + self[:ham]
  end

  def self.total_count
    self['words'].total_count
  end

  def self.increment_all(category)
    # should there be cache load ???
    SpamClassifier::FEATURES.each do |feature|
      self[feature].increment(category)
    end
  end

  def self.fetch_all
    examples = all(:conditions => '`key` LIKE "training_examples_with_feature::%"')
    examples.inject({}) do |memo, example|
      memo[example.key] = example
      memo
    end
  end

end
