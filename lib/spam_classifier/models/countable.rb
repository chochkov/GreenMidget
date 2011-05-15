# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module SpamClassifier
  class Countable
    include Constants
    attr_accessor :key

    def self.prefix; '' end

    def initialize(key)
      @key = self.class.prefix + key
    end

    def self.[](key)
      new(key)
    end

    def self.many(keys)
      keys.map { |key| new(key) }
    end

    def [](category)
      SpamClassificationIndex[record_key(category)].value.to_f
    end

    def increment(category)
      SpamClassificationIndex[record_key(category)].increment
    end

    def record_key(category)
      self.key + "::#{category}_count"
    end
  end
end
