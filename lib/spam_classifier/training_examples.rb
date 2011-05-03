module SpamClassifier
  class TrainingExamples < SpamClassificationIndex
    def self.[](feature)
      record = super("training_examples_with_feature::#{feature}")

      if record.no_examples? && (feature == 'any')
        raise ZeroDivisionError.new('Training examples must be provided for both spam and ham messages before classification')
      elsif record.no_examples?
        self['any']
      else
        record
      end
    end

    def self.with_words
      self['any']
    end

    # examples in category v.s. all examples
    def probability_for(category)
      self[category] / total_count
    end

    def self.probability_for(category)
      self['any'].probability_for(category)
    end

    def total_count
      self[:spam] + self[:ham]
    end

    def self.total_count
      self['any'].total_count
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

    def no_examples?
      (self[:spam] * self[:ham]) == 0
    end
  end
end
