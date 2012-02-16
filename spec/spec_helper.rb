# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov

require 'green_midget'
require 'sqlite3'

conn = { :adapter => 'sqlite3', :database => ':memory:' }
ActiveRecord::Base.establish_connection(conn)

require 'green_midget/db/migrate/create_green_midget_records'
GreenMidget::CreateGreenMidgetRecords.verbose = false
GreenMidget::CreateGreenMidgetRecords.up

