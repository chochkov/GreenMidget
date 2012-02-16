# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
#
# This is an abstraction from Words, Examples and Features. It provides common
# methods for building the record keys for individual countables in any
# category.
#
# For example the data record key for the word 'legit' in Spam category would
# be something like "word::legit::spam_count". The record key for a feature
# 'url_present' in Ham would be something like "feature::url_present::ham_count"
# The count of all training examples given for category Spam would be
# "example::any::spam_count"
#
# The example counts for individual features is stored as well. For example for
# 'url_present' we will have two records: "example::url_present::spam_count" and
# "example::url_present::ham_count". They will store the informatino about how
# much training the GreenMidget received for this feature in each category.
#
# This class is the link between countable and the Records data store adapter
#
module GreenMidget
  class Countable
    attr_accessor :key
    class_attribute :prefix

    def initialize(key)
      @key = self.class.prefix + key
    end

    class << self
      alias :[] :new

      def objects(keys)
        keys.map { |key| new(key) }
      end
    end

    def [](category)
      Records[record_key(category)].to_f
    end

    def log_ratio
      Math::log(probability_for(ALTERNATIVE) / probability_for(NULL))
    end

    def record_key(category)
      "#{self.key}::#{category}_count"
    end
  end
end

