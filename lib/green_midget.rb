# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'active_record'

require 'green_midget/constants'
require 'green_midget/url_detection'
require 'green_midget/logger'
require 'green_midget/heuristic_checks'
require 'green_midget/default_features'
require 'green_midget/base'

require 'green_midget/models/countable'
require 'green_midget/models/examples'
require 'green_midget/models/features'
require 'green_midget/models/records'
require 'green_midget/models/words'

require 'green_midget/errors/no_text_found'
require 'green_midget/errors/feature_method_not_implemented'
require 'green_midget/errors/no_examples_given'

require 'green_midget/extensions/classifier'

if classifier = Gem.searcher.find('green_midget')
  path = classifier.full_gem_path
  Dir["#{path}/lib/tasks/*.rake"].each { |ext| load ext }
end

