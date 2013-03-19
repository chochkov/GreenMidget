# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
#
# GreenMidget's simple data store adapter with only three public methods.
# It's currently ActiveRecord based but a plan is to make a
# Redis based extension as well.
#
module GreenMidget
  class Records < ActiveRecord::Base
    attr_accessible :key, :value
    self.table_name = :green_midget_records

    # Does a multi-get of the necessary count records for the given words.
    # If no words are given, then only Examples and Features counts are taken
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

    # Reads the value for a given key looking in the cache first and doing a
    # database call if nothing is found.
    def self.[](key)
      key = key.to_s
      @@cache ||= {}
      @@cache[key] ||= where(:key => key).select(:value).map(&:value).first || ''
    end

    # Increment the values for given keys. The AR implementation increments each
    # record individually, but implementing a multi-set is possible within this
    # method.
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

