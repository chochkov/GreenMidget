# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  class Countable
    attr_accessor :key
    class_attribute :prefix

    def self.[](key)
      new(key)
    end

    def self.objects(keys)
      keys.map { |key| new(key) }
    end

    def initialize(key)
      @key = self.class.prefix + key
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

