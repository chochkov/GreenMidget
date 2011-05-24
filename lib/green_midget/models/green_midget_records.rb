# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  class GreenMidgetRecords < ActiveRecord::Base
    set_table_name :green_midget_records

    def self.fetch_all(words = [])
      words_keys = Words.record_keys(words)

      records = connection.select_rows(
        "SELECT `key`, `value` FROM %s WHERE `key` IN ('%s') OR `key` LIKE '%s' OR `key` LIKE '%s'" %
        [ table_name, words_keys.join("', '"), Features.prefix + '%', Examples.prefix + '%' ]
      )

      @@cache = records.inject({}) do |memo, record|
        memo[record.first] = record.last
        memo
      end

      words_keys.inject(@@cache) do |memo, word|
        memo[word] ||= "0.0"
        memo
      end
    end

    def self.write!
      @@cache ||= {}
      @@cache.map { |key, value| find_or_create_by_key(key).update_attribute(:value, value) }
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
      @@cache[key]
      self.value = value.to_f + 1
      self
    end

    private_class_method :new
  end
end
