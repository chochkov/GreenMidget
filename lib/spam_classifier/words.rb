module SpamClassifier
  class Words < SpamClassificationIndex
    def self.[](key)
      super("word::#{key}")
    end

    # Pr(word | category)
    def probability_for(category)
      self[category] / TrainingExamples.with_words[category]
    end

    def self.increment_many(words, category)
      superclass.fetch_all(words)
      words.each { |word| Words[word].increment(category) }
    end

    def self.fetch_many(words)
      word_keys   = words.map{ |word| "word::#{word}" }
      known_keys  = all(:conditions => [ '`key` IN (?)', word_keys ])

      cache = known_keys.inject({}) do |memo, word|
        memo[word.key] = word
        memo
      end

      words.inject(cache) do |memo, word|
        memo[word] ||= new(word)
        memo
      end
    end
  end
end
