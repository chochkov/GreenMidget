module SpamClassifier
  module PublicMethods
    def classify
      pass_ham_heuristics? || pass_spam_heuristics?

      unless pass_ham_heuristics?
        classify_as! :ham
        return IS_HAM
      end
      unless pass_spam_heuristics?
        classify_as! :spam
        return IS_SPAM
      end

      SpamClassificationIndex.fetch_all(words)
      log_classification

      ratio = spam_ham_ratio
      case
      when ratio >= SPAM_THRESHOLD
        IS_SPAM
      when ratio >= 1.0
        DUNNO
      else
        IS_HAM
      end
    end

    def classify_as!(category)
      SpamClassificationIndex.fetch_all(words)

      Words.increment_many(words, category)
      TrainingExamples.increment_all(category)

      FEATURES.each do |feature|
        if send("#{feature}?")
          Features[feature].increment(category)
        end
      end

      SpamClassificationIndex.write!
      log_training
    end
  end
end
