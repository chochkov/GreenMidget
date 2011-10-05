# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'active_record'
require 'green_midget/green_midget'
require 'green_midget/base'
require 'green_midget/models/countable'
require 'green_midget/models/examples'
require 'green_midget/models/features'
require 'green_midget/models/green_midget_records'
require 'green_midget/models/words'
require 'green_midget/extensions/classifier'

if (classifier = Gem.searcher.find('green_midget'))
  path = classifier.full_gem_path
  Dir["#{path}/lib/tasks/*.rake"].each { |ext| load ext }
end

