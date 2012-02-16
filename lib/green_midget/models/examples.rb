# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
#
# A model for Examples used in GreenMidget. Examples represent the counts for
# how much training GreenMidget received in each respective category.
#
#   Example['url_present'][:spam]
#   # the number of spam training examples having an URL
#
#   Example['any'][:ham]
#   # the number of total Ham training examples 
#
# See Countable
#
module GreenMidget
  class Examples < Countable
    GENERAL_FEATURE_NAME    = 'any'
    self.prefix             = 'examples_with_feature::'

    def self.[](feature)
      object = super(feature)

      if object.no_examples? && (feature == GENERAL_FEATURE_NAME)
        raise NoExamplesGiven
      elsif object.no_examples?
        super GENERAL_FEATURE_NAME
      else
        object
      end
    end

    def self.objects(features, with_general = false)
      features += with_general ? [ GENERAL_FEATURE_NAME ] : []
      super(features)
    end

    def self.log_ratio
      self[GENERAL_FEATURE_NAME].log_ratio
    end

    def self.total
      @@total ||= self[GENERAL_FEATURE_NAME].total
    end

    def probability_for(category)
      self[category] / total
    end

    def total
      CATEGORIES.inject(0) { |memo, category| memo += self[category] }
    end

    def no_examples?
      CATEGORIES.inject(1) { |memo, category| memo *= self[category] } == 0
    end

    # These methods store the total ham and spam examples count
    #
    class_eval(<<-EVAL, __FILE__, __LINE__ + 1)
      def self.#{ ALTERNATIVE }                                         # def self.ham
        @@alternative ||= self[GENERAL_FEATURE_NAME][ALTERNATIVE]       #   @@alternative ||= self[GENERAL_FEATURE_NAME][ALTERNATIVE]
      end                                                               # end

      def self.#{ NULL }                                                # def self.spam
        @@null ||= self[GENERAL_FEATURE_NAME][NULL]                     #   @@null ||= self[GENERAL_FEATURE_NAME][NULL]
      end                                                               # end
    EVAL
  end
end
