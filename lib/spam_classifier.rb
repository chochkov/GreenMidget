# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
# TODO: do we need that here ?
require 'active_record'

require File.join(File.expand_path(__FILE__), '..', 'spam_classifier', 'spam_classifier')

require File.join(File.expand_path(__FILE__), '..', 'spam_classifier', 'base')
require File.join(File.expand_path(__FILE__), '..', 'spam_classifier', 'models', 'spam_classification_index')
require File.join(File.expand_path(__FILE__), '..', 'spam_classifier', 'models', 'words')
require File.join(File.expand_path(__FILE__), '..', 'spam_classifier', 'models', 'features')
require File.join(File.expand_path(__FILE__), '..', 'spam_classifier', 'models', 'training_examples')
require File.join(File.expand_path(__FILE__), '..', '..', 'extensions', 'spam_check')

if (classifier = Gem.searcher.find('spam_classifier'))
  path = classifier.full_gem_path
  Dir["#{path}/lib/tasks/*.rake"].each { |ext| load ext }
end

ActiveRecord::Base.establish_connection(:adapter => 'mysql', :username => 'root', :password => 'root', :database => 'soundcloud_development_temp')
