# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'fileutils'
require 'rake'
require File.join(File.dirname(__FILE__), '..', '..', 'db', 'migrate', 'create_green_midget_records')

namespace :green_midget do
  desc "prepare this project for a world without spam"
  task :setup => :environment do
    include GreenMidget

    unless GreenMidgetRecords.table_exists?
      CreateGreenMidgetRecords.up
    end

    keys = ["url_in_text", "email_in_text"].map do |feature|
      [ Features[feature].record_key(ALTERNATIVE), Features[feature].record_key(NULL) ]
    end.flatten

    keys += [Examples::GENERAL_FEATURE_NAME, "url_in_text", "email_in_text"].map do |feature|
      [ Examples[feature].record_key(ALTERNATIVE), Examples[feature].record_key(NULL) ]
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
