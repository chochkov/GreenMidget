# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
# TODO: do we need that here ?
require 'active_record'

require File.join(File.expand_path(__FILE__), '..', 'green_midget', 'green_midget')
require File.join(File.expand_path(__FILE__), '..', 'green_midget', 'base')

Dir["#{File.dirname(__FILE__)}/green_midget/models/*.rb"].each do |model|
  require model
end

require File.join(File.expand_path(__FILE__), '..', '..', 'extensions', 'spam_check')

if (classifier = Gem.searcher.find('green_midget'))
  path = classifier.full_gem_path
  Dir["#{path}/lib/tasks/*.rake"].each { |ext| load ext }
end

# This must go !
ActiveRecord::Base.establish_connection(:adapter => 'mysql', :username => 'root', :password => 'root', :database => 'classifier_development_weird')
