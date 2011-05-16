# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'spec_helper'

describe GreenMidget::Words do
  include GreenMidget

  before(:each) do
    Words.delete_all
  end

  # describe "#[]()" do
  #   it "should return an instance of class Words" do
  #     Words['word'].class.should == Words
  #   end
  #   it "should first look in the cache and take the value from there if it exists" do
  #     Words.fetch_all([ 'word', 'phrase' ])
  #     Words.find_by_key(Words::PREFIX + "word").should == nil
  #     Words['word'].should_not == nil
  #   end
  #   it "should take words from data store if not found in the cache" do
  #     Words.fetch_all([ 'word' ])
  #     Words.create!(Words::PREFIX + "phrase")
  #     Words.find_by_key(Words::PREFIX + "word").should == nil
  #     Words.find_by_key(Words::PREFIX + "phrase").should_not == nil
  #     Words['phrase'].should == Words.find_by_key(Words::PREFIX + "phrase")
  #   end
  #   it "should create new object if no key found in the datastore and add to the cache" do
  #     Words['nonexisting'].should.eql? Words.class_eval{ new(GreenMidget::Words::PREFIX + 'nonexisting') }
  #     Words.find_by_key(Words::PREFIX + 'nonexisting').should == nil
  #   end
  # end
  # 
  # describe "#increment_many" do
  #   it "returns the spam count for a given word" do
  #     Words.increment_many([ 'foo' ], :spam)
  #     Words['foo'][:spam].should == 1
  #     Words['foo'][:ham].should == 0
  #   end
  #   it "should reload the cache before incrementing" do
  #     Words.increment_many([ 'foo', 'bar' ], :spam)
  #     Words.class_variable_get("@@cache")[Words::PREFIX + "bar"].should_not == nil
  #     Words.increment_many([ 'foo', 'newbar' ], :spam)
  #     Words.class_variable_get("@@cache")[Words::PREFIX + "bar"].should == nil
  #   end
  #   it "should increment the values in the cache" do
  #     Words.class_variable_get("@@cache")[Words::PREFIX + "bar"].should == nil
  #     Words.increment_many([ 'foo', 'bar' ], :spam)
  #     Words.class_variable_get("@@cache")[Words::PREFIX + "bar"][:spam].should == 1.0
  #   end
  #   it "increments the spam/ham count for a given key to the data source" do
  #     Words.increment_many([ 'foo', 'bar' ], :spam)
  #     Words.write!
  #     Words.find_by_key(Words::PREFIX + "foo")[:spam].should == 1
  #     Words.find_by_key(Words::PREFIX + "foo")[:ham].should == 0
  # 
  #     # unless the cache has been written -> increment the cache but not the store,
  #     # once we wrote the cache to the store -> well.. increment the store:
  #     Words.increment_many([ 'foo' ], :spam)
  #     Words.find_by_key(Words::PREFIX + "foo")[:spam].should == 1
  #     Words.write!
  #     Words.find_by_key(Words::PREFIX + "foo")[:spam].should == 2
  # 
  #     # and again for the other category..
  #     Words.find_by_key(Words::PREFIX + "foo")[:ham].should == 0
  #     Words.increment_many([ 'foo' ], :ham)
  #     Words.find_by_key(Words::PREFIX + "foo")[:ham].should == 0
  #     Words.write!
  #     Words.find_by_key(Words::PREFIX + "foo")[:ham].should == 1
  #   end
  # end
end
