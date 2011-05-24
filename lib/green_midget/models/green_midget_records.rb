# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  class GreenMidgetRecords < ActiveRecord::Base
    set_table_name :green_midget_records

    def self.fetch_all(words = [])
      words_keys = Words.record_keys(words)

      pairs = connection.select_rows(
        "SELECT `key`, `value` FROM %s WHERE `key` IN ('%s') OR `key` LIKE '%s' OR `key` LIKE '%s'" %
        [ table_name, words_keys.join("', '"), "#{ Features.prefix }%", "#{ Examples.prefix }%" ]
      )

      @@cache = pairs.inject({}) do |memo, pair|
        memo[pair.first] = pair.last
        memo
      end

      words_keys.inject(@@cache) do |memo, word|
        memo[word] ||= nil
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
      @@cache[key] || @@cache[key] = connection.select_value("SELECT `value` FROM #{ table_name } WHERE `key` = '#{ key }'") || @@cache[key] = nil
    end

    def self.increment(keys)
      Array(keys).map { |key| @@cache[key] = @@cache[key].to_f + 1 }
    end
  end
end
