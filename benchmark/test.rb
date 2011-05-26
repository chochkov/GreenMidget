require 'sqlite3'

require File.join(File.dirname(__FILE__), '..', 'spec', 'tester')
include GreenMidget

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => '/sc/user_backup/data.db')

@spam = [ 'messages', 'comments', 'posts' ].map { |table| ActiveRecord::Base.connection.execute("select body from #{table} limit 1500").inject([]) { |memo, hash| memo << hash["body"] } }

ActiveRecord::Base.establish_connection(:adapter => 'mysql', :username => 'root', :password => 'root', :database => 'soundcloud_development_temp')

@ham  = [ 'messages', 'comments', 'posts' ].map { |table| GreenMidgetRecords.find_by_sql("select body from #{table} limit 1500").to_a.inject([]) { |memo, hash| memo << hash["body"] } }

ActiveRecord::Base.establish_connection(:adapter => 'mysql', :username => 'root', :password => 'root', :database => 'classifier_development_weird')
# 
# # ------ I. PERFORM TRAINING
# puts Benchmark.measure {
#   @spam.each { |src|
#     src.each {|body|
#       klass = Tester.new(body);klass.classify_as! :spam
#     }
#   };true
# }
# 
# puts Benchmark.measure {
#   @ham.each { |src|
#     src.each {|body|
#       klass = Tester.new(body);klass.classify_as! :ham
#     }
#   };true
# }