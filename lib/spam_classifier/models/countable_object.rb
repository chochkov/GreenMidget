# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module SpamClassifier
  class CountableObject
    include Constants
    attr_accessor :key

    CATEGORIES.each { |category| attr_accessor category }

    def self.[](key)
      word = new
      word.key = key
      CATEGORIES.each do |category|
        send("#{category}_count=", SpamClassificationIndex[PREFIX + key + "::#{category}_count"].value)
      end
      word
    end

    def [](category)
      send("#{category}_count").to_f
    end
  end
end
