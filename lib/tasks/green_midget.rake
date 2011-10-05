# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'fileutils'
require 'rake'
require 'green_midget/db/migrate/create_green_midget_records'

namespace :green_midget do
  namespace :setup do
    desc "prepare this project for a world without spam using ActiveRecord"
    task :active_record => :environment do
      include GreenMidget

      unless GreenMidgetRecords.table_exists?
        CreateGreenMidgetRecords.up
      end

      keys = [ ALTERNATIVE, NULL ].map do |hypothesis|
        [
          "feature::url_in_text::#{hypothesis}_count",
          "feature::email_in_text::#{hypothesis}_count",
          "examples::any::#{hypothesis}_count",
          "examples::url_in_text::#{hypothesis}_count",
          "examples::email_in_text::#{hypothesis}_count",
        ]
      end.flatten

      puts '==  Creating records ==='
      keys.each { |key|
        unless GreenMidgetRecords.find_by_key(key)
          GreenMidgetRecords.create(key)
          puts "--  Created #{key}"
        end
      }
      puts '==  Done ==='
    end
  end
end
