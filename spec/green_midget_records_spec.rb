# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'spec_helper'

describe GreenMidget::GreenMidgetRecords do
  include GreenMidget

  before(:each) do
    GreenMidgetRecords.delete_all
  end
  
  describe "#fetch_all" do
    it "should empty cache before fetching" do
      GreenMidgetRecords.fetch_all([ 'foo', 'bar' ])
      GreenMidgetRecords.class_variable_get("@@cache")[Words['bar'].record_key(:spam)].should_not == nil
      GreenMidgetRecords.fetch_all(['foo', 'newbar'])
      GreenMidgetRecords.class_variable_get("@@cache")[Words['bar'].record_key(:spam)].should == nil
    end
  
    it "does a multi get on all words and keys" do
      cache = GreenMidgetRecords.fetch_all([ 'foo', 'bar' ])
      cache['foo'].should.eql? GreenMidgetRecords.class_eval{new('foo')}
    end
  
    it "should fetch the system keys along with the given words" do
      Examples.create!(Examples::PREFIX + 'any')
      GreenMidgetRecords.fetch_all([])
      cache = GreenMidgetRecords.class_variable_get("@@cache")
      cache[Examples::PREFIX + 'any'].should_not == nil
      cache.count.should == 1
    end
  
    it "the cache should be a hash; its keys should be strings" do
      GreenMidgetRecords.create!(Examples::PREFIX + Examples::GENERAL_FEATURE_NAME)
      GreenMidgetRecords.create!(Features::PREFIX + 'url_in_text')
      GreenMidgetRecords.create!('oneword')
      GreenMidgetRecords.fetch_all([ 'oneword' ])
      cache = GreenMidgetRecords.class_variable_get("@@cache")
      cache.class.should.eql? Hash
      cache.count.should == 3
      cache.keys.each do |key|
        key.class.should.eql? String
      end
    end
  
    it "should touch the data store only once per request" do
      pending('find a way to assert this - in the new refactoring it should touch it exactly three times!')
      # GreenMidgetRecords.create!('word')
      # GreenMidgetRecords.create!('other')
      # GreenMidgetRecords.fetch_all([ 'word', 'other' ])
    end
  end
  # 
  # describe "#increment" do
  #   it "should increment counts first in cache and write! to store only if explicitly called" do
  #     lambda {
  #       GreenMidgetRecords['stuff'].increment(:spam)
  #     }.should change { GreenMidgetRecords['stuff'][:spam] }.by(1)
  # 
  #     GreenMidgetRecords.write!
  # 
  #     lambda {
  #       GreenMidgetRecords['stuff'].increment(:spam)
  #     }.should_not change { GreenMidgetRecords.find_by_key('stuff')[:spam] }
  #   end
  # end
end
