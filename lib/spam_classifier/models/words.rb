# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module SpamClassifier
  class Words < SpamClassificationIndex
    PREFIX = 'word::'

    def self.[](key)
      super(PREFIX + key)
    end

    # Pr(word | category)
    def probability_for(category)
      self[category] / TrainingExamples.any[category]
    end

    def self.increment_many(words, category)
      superclass.fetch_all(words)
      words.each { |word| Words[word].increment(category) }
    end

    def self.fetch_many(words)
      word_keys   = words.map{ |word| PREFIX + word }
      known_keys  = all(:conditions => [ '`key` IN (?)', word_keys ])

      cache = known_keys.inject({}) do |memo, word|
        memo[word.key] = word
        memo
      end

      word_keys.inject(cache) do |memo, word|
        memo[word] ||= new(word)
        memo
      end
    end
  end
end
