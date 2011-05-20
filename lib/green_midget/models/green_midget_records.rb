# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  class GreenMidgetRecords < ActiveRecord::Base
    set_table_name :green_midget_records

    def self.fetch_all(words = [])
      words_keys = Words.record_keys(words)
      records = all(:conditions => [ "`key` IN (?) OR `key` LIKE '#{ Features.prefix }%' OR `key` LIKE '#{ Examples.prefix }%'", words_keys ])

      @@cache = records.inject({}) do |memo, record|
        memo[record.key] = record
        memo
      end

      words_keys.inject(@@cache) do |memo, word|
        memo[word] ||= new(word)
        memo
      end
    end

    def self.write!
      @@cache ||= {}
      @@cache.map(&:last).map(&:save)
      written_cache = @@cache
      @@cache = {}
      written_cache
    end

    def self.[](key)
      key = key.to_s
      @@cache ||= {}
      @@cache[key] || @@cache[key] = find_by_key(key) || @@cache[key] = new(key)
    end

    def self.new(key, value = nil)
      super(:key => key, :value => value || 0.0)
    end

    def self.increment(keys)
      keys.each { |key| self[key].increment }
    end

    def increment
      raise "#increment called on a non countable object!" unless key =~ /_count$/
      self.value = value.to_f + 1
      self
    end

    private_class_method :new
  end
end
