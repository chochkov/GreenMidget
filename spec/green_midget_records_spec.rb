# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'spec_helper'

describe GreenMidget::GreenMidgetRecords do
  include GreenMidget

  before(:each) do
    GreenMidgetRecords.delete_all
  end

  describe "#[]()" do
    it "should take words from data store if not found in the cache" do
      word_key, phrase_key = [ 'word', 'phrase' ].map { |w| Words[w].record_key(NULL) }
      GreenMidgetRecords.fetch_all([ 'word' ])
      GreenMidgetRecords.create(:key => phrase_key)
      GreenMidgetRecords.find_by_key(word_key).should == nil
      GreenMidgetRecords.find_by_key(phrase_key).should_not == nil
      GreenMidgetRecords[phrase_key].should == GreenMidgetRecords.find_by_key(phrase_key).value
    end
    it "should add a {key => ''} to the cache if key not found in cache and in the data store" do
      key = Words['nonexisting'].record_key(NULL)
      GreenMidgetRecords[key].should == nil
      GreenMidgetRecords.find_by_key(key).should == nil
    end
  end

  describe "#fetch_all" do
    it "should empty cache before fetching" do
      bar_key = Words['bar'].record_key(ALTERNATIVE)
      GreenMidgetRecords.fetch_all([ 'foo', 'bar' ])
      GreenMidgetRecords.class_variable_get("@@cache").key?(bar_key).should be_true
      GreenMidgetRecords.fetch_all([ 'foo', 'newbar' ])
      GreenMidgetRecords.class_variable_get("@@cache").key?(bar_key).should be_false
    end
    it "does a multi get on all words and keys" do
      cache = GreenMidgetRecords.fetch_all([ 'foo', 'bar' ])
      cache['foo'].should.eql? GreenMidgetRecords.class_eval{new('foo')}
    end
    it "should fetch the system keys along with the given words" do
      key = Examples.prefix + Examples::GENERAL_FEATURE_NAME + "::#{ NULL }_count"
      GreenMidgetRecords.create(:key => key)
      GreenMidgetRecords.fetch_all([])
      cache = GreenMidgetRecords.class_variable_get("@@cache")
      cache.key?(key).should be_true
      cache.count.should == 1
    end
    it "words with zero examples or no record in the database should be present in the cache" do
      GreenMidgetRecords.create(:key => Words['kotoba'].record_key(NULL))
      GreenMidgetRecords.fetch_all(['kotoba'])
      GreenMidgetRecords.class_variable_get("@@cache").key?(Words['kotoba'].record_key(ALTERNATIVE)).should be_true
      GreenMidgetRecords.create(:key => Words['mouichidou'].record_key(NULL),        :value => 0)
      GreenMidgetRecords.create(:key => Words['mouichidou'].record_key(ALTERNATIVE), :value => 3)
      GreenMidgetRecords.fetch_all(['mouichidou'])
      GreenMidgetRecords.class_variable_get("@@cache")[Words['mouichidou'].record_key(NULL)].should_not == nil
      GreenMidgetRecords.class_variable_get("@@cache")[Words['mouichidou'].record_key(ALTERNATIVE)].should_not == nil
    end
    it "the cache should be a hash; its keys should be strings" do
      GreenMidgetRecords.create(:key => Examples.prefix + Examples::GENERAL_FEATURE_NAME + "::#{ NULL }_count")
      GreenMidgetRecords.create(:key => Features.prefix + "url_in_text::#{ NULL }_count")
      GreenMidgetRecords.fetch_all([])
      cache = GreenMidgetRecords.class_variable_get("@@cache")
      cache.class.should.eql? Hash
      cache.count.should == 2
      cache.keys.each do |key|
        key.class.should.eql? String
      end
    end
  end

  describe "#increment" do
    it "should increment counts first in cache and write! to store only if explicitly called" do
      record_key = Words['stuff'].record_key(NULL)
      GreenMidgetRecords.create(:key => record_key)

      lambda {
        GreenMidgetRecords.increment(record_key)
      }.should change { GreenMidgetRecords[record_key].to_f }.by(1)

      lambda {
        GreenMidgetRecords.write!
      }.should change { GreenMidgetRecords.find_by_key(record_key).value.to_f }.by(1)

      lambda {
        GreenMidgetRecords.increment(record_key)
      }.should_not change { GreenMidgetRecords.find_by_key(record_key).value.to_f }
    end
  end
end
