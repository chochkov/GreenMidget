# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
class CreateSpamClassificationIndex < ActiveRecord::Migration
  def self.up
    create_table :spam_classification_index do |t|
      t.string   :key
      t.string   :value
      t.datetime :updated_at
    end
    add_index :spam_classification_index, :key
    add_index :spam_classification_index, :updated_at
  end

  def self.down
    drop_table :spam_classification_index
  end
end
