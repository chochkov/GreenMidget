# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'green_midget'
require 'sqlite3'

conn = { :adapter => 'sqlite3', :database => ':memory:'}
ActiveRecord::Base.establish_connection(conn)

require 'green_midget/db/migrate/create_green_midget_records'
GreenMidget::CreateGreenMidgetRecords.up

RSpec.configure do |config|
end
