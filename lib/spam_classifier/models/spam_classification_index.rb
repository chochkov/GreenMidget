# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module SpamClassifier
  class SpamClassificationIndex < ActiveRecord::Base
    set_table_name :spam_classification_index

    def self.fetch_all(words = [])
      words     = Words.fetch_many(words)
      features  = Features.fetch_all
      examples  = TrainingExamples.fetch_all

      @@cache = [ words, features, examples ].inject({}) do |memo, hash|
        memo.merge!(hash)
      end
    end

    def self.write!
      @@cache ||= {}
      @@cache.map(&:last).map(&:save)
      @@cache = {}
    end

    def self.[](key)
      key = key.to_s
      @@cache ||= {}
      @@cache[key] || @@cache[key] = find_by_key(key) || @@cache[key] = new(key)
    end

    def self.new(word, spam_count = nil, ham_count = nil)
      super(:key => word, :spam_count => spam_count || 0, :ham_count => ham_count || 0)
    end

    def [](category)
      send("#{category}_count").to_f
    end

    def increment(category)
      category = category.to_sym
      send("#{category}_count=", self[category] + 1)
      self
    end

    private_class_method :new
  end
end
