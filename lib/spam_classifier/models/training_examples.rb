module SpamClassifier
  class TrainingExamples < SpamClassificationIndex
    PREFIX = 'training_examples_with_feature::'

    def self.[](feature)
      record = super(PREFIX + feature.to_s)

      if record.no_examples? && (feature == 'any')
        raise ZeroDivisionError.new('Training examples must be provided for both spam and ham messages before classification')
      elsif record.no_examples?
        self['any']
      else
        record
      end
    end

    def self.any
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

    def self.increment_many(features, category)
      features.each do |feature|
        begin
          self[feature].increment(category)
        rescue ZeroDivisionError
          superclass.create!(PREFIX + 'any').increment(category)
        end
      end
    end

    def self.fetch_all
      examples = all(:conditions => "`key` LIKE '#{ PREFIX }%'")
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
