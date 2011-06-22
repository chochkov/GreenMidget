include GreenMidget

TRAININGS               = 90
CLASSIFICATIONS         = 1

MESSAGE_LENGTH          = 1000

@training_times         = []
@classification_times   = []

records_count_at_start  = GreenMidgetRecords.count

def generate_text(message_length = 1)
  message ||= []
  while message.count < message_length do
    word = ''
    (rand(7) + 3).times { word += ('a'..'z').to_a[rand(26)] }
    message << word unless message.include?(word)
  end
  text = message.join(' ')
end

TRAININGS.times do
  a = GreenMidgetCheck.new generate_text(MESSAGE_LENGTH)
  @training_times       << Benchmark.measure{ a.classify_as! [ ALTERNATIVE, NULL ][rand(2)] }.real
end

CLASSIFICATIONS.times do
  a = GreenMidgetCheck.new generate_text(MESSAGE_LENGTH)
  @classification_times << Benchmark.measure{ a.classify }.real
end

puts " ------------------------------- "
puts " Average seconds from #{ TRAININGS } trainings and #{ CLASSIFICATIONS } classifications. #{ MESSAGE_LENGTH } words per message:"
puts " Number of records at start: #{ records_count_at_start } and at the end: #{ GreenMidgetRecords.count }"
puts " ------------------------------- "
puts " Training times:                 #{ (@training_times.sum.to_f/TRAININGS).round(4) }"
puts " ------------------------------- "
puts " Classification times:           #{ (@classification_times.sum.to_f/CLASSIFICATIONS).round(4) }"
puts " ------------------------------- "
