# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module SpamClassifier
  class SpamClassificationIndex < ActiveRecord::Base
    set_table_name :spam_classification_index

    def self.fetch_all(words = [])
      word_keys = words.map{ |word| [ Words::PREFIX + word + '::spam_count', Words::PREFIX + word + '::ham_count' ] }.flatten
      records = all(:conditions => [ "`key` IN (?) OR `key` LIKE '#{ Features::PREFIX }%' OR `key` LIKE '#{ Examples::PREFIX }%'", word_keys ])

      @@cache = records.inject({}) do |memo, record|
        memo[record.key] = record
        memo
      end

      word_keys.inject(@@cache) do |memo, word|
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
      raise ArgumentError.new("#increment called on a non countable object!") unless key =~ /_count$/
      self.value = value.to_f + 1
      self
    end

    private_class_method :new
  end
end
