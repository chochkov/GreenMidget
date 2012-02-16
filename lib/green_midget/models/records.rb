# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  class Records < ActiveRecord::Base
    set_table_name :green_midget_records

    def self.fetch_all(words = [])
      words_keys = Words.record_keys(words)

      pairs = where(arel_table[:key].in(words_keys).
                    or(arel_table[:key].matches("#{Features.prefix}%")).
                    or(arel_table[:key].matches("#{Examples.prefix}%"))).
              select(:key).select(:value)

      @@cache = pairs.inject({}) do |memo, pair|
        memo[pair['key']] = pair['value']
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
      @@cache[key] ||= where(:key => key).pluck(:value).first || ''
    end

    def self.increment(keys)
      keys = Array(keys)

      @@objects = where(:key => keys).inject({}) do |memo, record|
        memo[record.key] = record
        memo
      end

      keys.inject(@@objects) do |memo, key|
        memo[key] ||= new(:key => key, :value => 0)
        memo
      end

      @@objects.each { |key, record| record.increment!(:value) }
      @@objects = {}
    end
  end
end

