# compare classification performance with caching and without (fast / slow)
#
require File.expand_path(File.dirname(__FILE__) + '/../spec/spam_test')

REPETITIONS     = 5
MESSAGE_LENGTH  = 1000

@train_shit = []
@train_cool = []
@slow       = []
@fast       = []

REPETITIONS.times do

  a = SpamTest.new_with_random_text(MESSAGE_LENGTH)

  @train_shit << Benchmark.measure{ a.classify_as! :spam }.real
  @train_cool << Benchmark.measure{ a.classify_as! :ham }.real

  SpamClassificationIndex.class_eval do
    def self.[](key)
      find_by_key(key)
    end
  end

  @slow << Benchmark.measure{ a.classify }.real

  SpamClassificationIndex.class_eval do
    def self.[](key)
      key = key.to_s
      @@cache ||= {}
      @@cache[key] || @@cache[key] = find_by_key(key) || @@cache[key] = new(key)
    end
  end

  @fast << Benchmark.measure{ a.classify }.real

end

puts "Average times from #{REPETITIONS} repetitions and #{MESSAGE_LENGTH} words per message"
puts "Spam training: #{@train_shit.sum.to_f/REPETITIONS}"
puts "Cool training: #{@train_cool.sum.to_f/REPETITIONS}"
puts "Classification without caching: #{@slow.sum.to_f/REPETITIONS}"
puts "Classification with caching: #{@fast.sum.to_f/REPETITIONS}"
