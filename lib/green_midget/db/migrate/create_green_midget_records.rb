# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  class CreateGreenMidgetRecords < ActiveRecord::Migration
    def self.up
      create_table :green_midget_records do |t|
        t.string   :key
        t.integer  :value
        t.datetime :updated_at
      end
      add_index :green_midget_records, :key
      add_index :green_midget_records, :updated_at
    end

    def self.down
      drop_table :green_midget_records
    end
  end
end
