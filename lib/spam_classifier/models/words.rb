# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module SpamClassifier
  class Words < CountableObject
    PREFIX = 'word::'

    # Pr(word | category)
    def probability_for(category)
      self[category] / TrainingExamples.any[category]
    end

    def self.increment_many(words, category)
      words.each do |key|
        SpamClassificationIndex["#{PREFIX + key}::#{category}_count"].increment
      end
    end
  end
end
