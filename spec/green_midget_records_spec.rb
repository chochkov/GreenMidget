# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'spec_helper'

describe GreenMidget::Records do
  include GreenMidget

  before(:each) do
    Records.delete_all
  end

  describe "#[]()" do
    it "should take words from data store if not found in the cache" do
      word_key, phrase_key = [ 'word', 'phrase' ].map { |w| Words[w].record_key(NULL) }
      Records.fetch_all([ 'word' ])
      Records.create(:key => phrase_key)
      Records.find_by_key(word_key).should == nil
      Records.find_by_key(phrase_key).should_not == nil
      Records[phrase_key].should == ''
    end
    it "should add a {key => ''} to the cache if key not found in cache and in the data store" do
      key = Words['nonexisting'].record_key(NULL)
      Records[key].should == ''
      Records.find_by_key(key).should == nil
    end
  end

  describe "#fetch_all" do
    it "should empty cache before fetching" do
      bar_key = Words['bar'].record_key(ALTERNATIVE)
      Records.fetch_all([ 'foo', 'bar' ])
      Records.class_variable_get("@@cache").key?(bar_key).should be_true
      Records.fetch_all([ 'foo', 'newbar' ])
      Records.class_variable_get("@@cache").key?(bar_key).should be_false
    end
    it "does a multi get on all words and keys" do
      cache = Records.fetch_all([ 'foo', 'bar' ])
      cache['foo'].should.eql? Records.class_eval{new(:key => 'foo')}
    end
    it "should fetch the system keys along with the given words" do
      key = Examples.prefix + Examples::GENERAL_FEATURE_NAME + "::#{ NULL }_count"
      Records.create(:key => key)
      Records.fetch_all([])
      cache = Records.class_variable_get("@@cache")
      cache.key?(key).should be_true
      cache.count.should == 1
    end
    it "words with zero examples or no record in the database should be present in the cache" do
      Records.create(:key => Words['kotoba'].record_key(NULL))
      Records.fetch_all(['kotoba'])
      Records.class_variable_get("@@cache").key?(Words['kotoba'].record_key(ALTERNATIVE)).should be_true
      Records.create(:key => Words['mouichidou'].record_key(NULL),        :value => 0)
      Records.create(:key => Words['mouichidou'].record_key(ALTERNATIVE), :value => 3)
      Records.fetch_all(['mouichidou'])
      Records.class_variable_get("@@cache")[Words['mouichidou'].record_key(NULL)].should_not == nil
      Records.class_variable_get("@@cache")[Words['mouichidou'].record_key(ALTERNATIVE)].should_not == nil
    end
    it "the cache should be a hash; its keys should be strings" do
      Records.create(:key => Examples.prefix + Examples::GENERAL_FEATURE_NAME + "::#{ NULL }_count")
      Records.create(:key => Features.prefix + "url_in_text::#{ NULL }_count")
      Records.fetch_all([])
      cache = Records.class_variable_get("@@cache")
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
      Records.create(:key => record_key)

      lambda {
        Records.increment(record_key)
      }.should change { Records.find_by_key(record_key).value.to_f }.by(1)
    end
  end
end
