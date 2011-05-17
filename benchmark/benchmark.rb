# Compare classification performance with caching and without (fast / slow)
require File.join(File.dirname(__FILE__), '..', 'spec', 'tester')
include GreenMidget

REPETITIONS        = 20
MESSAGE_LENGTH     = 1000

@train_alternative = []
@train_null        = []
@no_caching        = []
@caching           = []

REPETITIONS.times do
  a = Tester.new_with_random_text(MESSAGE_LENGTH)

  @train_alternative << Benchmark.measure{ a.classify_as! CATEGORIES.last }.real
  @train_null        << Benchmark.measure{ a.classify_as! CATEGORIES.first }.real

  GreenMidgetRecords.class_eval do
    def self.[](key)
      find_by_key(key)
    end
  end
  @no_caching << Benchmark.measure{ a.classify }.real

  GreenMidgetRecords.class_eval do
    def self.[](key)
      key = key.to_s
      @@cache ||= {}
      @@cache[key] || @@cache[key] = find_by_key(key) || @@cache[key] = new(key)
    end
  end
  @caching    << Benchmark.measure{ a.classify }.real
end

puts "Average times from #{ REPETITIONS } repetitions and #{ MESSAGE_LENGTH } words per message"
puts "Examples in the alternative hypothesis: #{ @train_alternative.sum.to_f/REPETITIONS  }"
puts "Examples in the null hypothesis: #{        @train_null.sum.to_f/REPETITIONS         }"
puts "Classification without caching: #{         @no_caching.sum.to_f/REPETITIONS         }"
puts "Classification with caching: #{            @caching.sum.to_f/REPETITIONS            }"
