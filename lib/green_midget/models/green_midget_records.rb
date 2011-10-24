# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  class GreenMidgetRecords < ActiveRecord::Base
    set_table_name :green_midget_records

    def self.fetch_all(words = [])
      words_keys = Words.record_keys(words)

      pairs = connection.select_rows(
        "SELECT key, value FROM %s WHERE key IN ('%s') OR key LIKE '%s' OR key LIKE '%s'" %
        [ table_name, words_keys.join("', '"), "#{ Features.prefix }%", "#{ Examples.prefix }%" ]
      )

      @@cache = pairs.inject({}) do |memo, pair|
        memo[pair.first] = pair.last
        memo
      end

      words_keys.inject(@@cache) do |memo, word|
        memo[word] ||= ''
        memo
      end
    end

    def self.[](key)
      key = key.to_s
      @@cache ||= {}
      @@cache[key] || @@cache[key] = connection.select_value("SELECT value FROM #{ table_name } WHERE key = '#{ key }'") || @@cache[key] = ''
    end

    def self.increment(keys)
      keys = Array(keys)
      records = all(:conditions => [ "key IN (?)", keys ])

      @@objects = records.inject({}) do |memo, record|
        memo[record.key] = record
        memo
      end

      keys.inject(@@objects) do |memo, key|
        memo[key] ||= new(:key => key, :value => '0.0')
        memo
      end

      @@objects.each { |key, record| record.update_attribute(:value, record.value.to_f + 1) }
      @@objects = {}
    end
  end
end

