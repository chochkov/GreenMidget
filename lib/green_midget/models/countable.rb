# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  class Countable
    include Constants
    attr_accessor :key

    class << self; attr_accessor :prefix end

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
      GreenMidgetRecords[record_key(category)].to_f
    end

    def log_ratio
      Math::log(probability_for(ALTERNATIVE) / probability_for(NULL))
    end

    def record_key(category)
      "#{self.key}::#{category}_count"
    end
  end
end

