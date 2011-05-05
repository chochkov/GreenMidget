require 'fileutils'
require 'rake'
require File.join(File.dirname(__FILE__), '..', '..', 'db', 'migrate', 'create_spam_classification_index')

namespace :spam_classifier do
  desc "prepare this project for a world without spam"
  task :setup => :environment do
    include SpamClassifier

    unless SpamClassificationIndex.table_exists?
      CreateSpamClassificationIndex.up
    end

    keys = ["url_in_text", "email_in_text"].map { |feature| Features::PREFIX + feature }
    keys += ["any", "url_in_text", "email_in_text"].map { |feature| TrainingExamples::PREFIX + feature }

    puts '=== Creating records ==='
    keys.each { |key| SpamClassificationIndex.create!(key) }
    puts "=== Done ==="
  end
end
