# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  class Examples < Countable
    PREFIX                  = 'examples_with_feature::'
    NO_EXAMPLES_GIVEN_ERROR = 'Training examples must be provided for all categories before classification.'
    GENERAL_FEATURE_NAME    = 'any'

    def self.prefix; PREFIX end

    def self.[](feature)
      object = super(feature)

      if object.no_examples? && (feature == GENERAL_FEATURE_NAME)
        raise ZeroDivisionError.new(NO_EXAMPLES_GIVEN_ERROR)
      elsif object.no_examples?
        super(GENERAL_FEATURE_NAME)
      else
        object
      end
    end

    def [](category)
      cache = "@@#{key}_#{category}_count"
      if (self.class.class_variable_defined?(cache))
        self.class.class_variable_get(cache)
      else
        self.class.class_variable_set(cache, super(category))
      end
    end

    def self.general
      self[GENERAL_FEATURE_NAME]
    end

    def self.objects(features, with_general = false)
      features += with_general ? [ GENERAL_FEATURE_NAME ] : []
      super(features)
    end

    def self.log_ratio
      Math::log((self[GENERAL_FEATURE_NAME].probability_for(:spam))/(self[GENERAL_FEATURE_NAME].probability_for(:ham)))
    end

    def self.total_count
      self[GENERAL_FEATURE_NAME].total_count
    end

    def probability_for(category)
      self[category] / total_count
    end

    def total_count
      CATEGORIES.inject(0) { |memo, category| memo += self[category] }
    end

    def no_examples?
      CATEGORIES.inject(1) { |memo, category| memo *= self[category] } == 0
    end
  end
end
