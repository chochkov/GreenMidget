# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'rake'
require 'green_midget/db/migrate/create_green_midget_records'

namespace :green_midget do
  namespace :setup do
    desc "prepare this project for a world without spam using ActiveRecord"
    task :active_record => :environment do
      include GreenMidget

      unless Records.table_exists?
        CreateGreenMidgetRecords.up
      end

      keys = [ ALTERNATIVE, NULL ].map do |hypothesis|
        FEATURES.map do |feature|
          [
            "#{Features.prefix}#{feature}::#{hypothesis}_count",
            "#{Examples.prefix}#{feature}::#{hypothesis}_count",
            "#{Examples.prefix}any::#{hypothesis}_count",
          ]
        end
      end.flatten

      puts '==  Creating records ==='
      keys.each { |key|
        unless Records.find_by_key(key)
          Records.create(:key => key, :value => 0)
          puts "--  Created #{key}"
        end
      }
      puts '==  Done ==='
    end
  end
end
