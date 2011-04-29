require 'spec_helper'

describe SpamClassifier::Words do
  before(:each) do
    SpamClassifier::Words.delete_all
  end

  describe "#[]()" do
    it "should return an instance of class SpamClassifier::Words" do
      SpamClassifier::Words['word'].class.should == SpamClassifier::Words
    end
    it "should first look in the cache and take the value from there if it exists" do
      SpamClassifier::Words.fetch_all([ 'word', 'phrase' ])
      SpamClassifier::Words.find_by_key('word::word').should == nil
      SpamClassifier::Words['word'].should_not == nil
    end
    it "should take words from data store if not found in the cache" do
      SpamClassifier::Words.fetch_all([ 'word' ])
      SpamClassifier::Words.create!('word::phrase')
      SpamClassifier::Words.find_by_key('word::word').should == nil
      SpamClassifier::Words.find_by_key('word::phrase').should_not == nil
      SpamClassifier::Words['phrase'].should == SpamClassifier::Words.find_by_key('word::phrase')
    end
    it "should create new object if no key found in the datastore and add to the cache" do
      SpamClassifier::Words['nonexisting'].should.eql? SpamClassifier::Words.class_eval{ new('word::nonexisting') }
      SpamClassifier::Words.find_by_key('word::nonexisting').should == nil
    end
  end

  describe "#increment_many" do
    it "returns the spam count for a given word" do
      SpamClassifier::Words.increment_many([ 'foo' ], :spam)
      SpamClassifier::Words['foo'][:spam].should == 1
      SpamClassifier::Words['foo'][:ham].should == 0
    end
    it "should reload the cache before incrementing" do
      SpamClassifier::Words.increment_many([ 'foo', 'bar' ], :spam)
      SpamClassifier::Words.class_variable_get("@@cache")['word::bar'].should_not == nil
      SpamClassifier::Words.increment_many([ 'foo', 'newbar' ], :spam)
      SpamClassifier::Words.class_variable_get("@@cache")['word::bar'].should == nil
    end
    it "should increment the values in the cache" do
      SpamClassifier::Words.class_variable_get("@@cache")['word::bar'].should == nil
      SpamClassifier::Words.increment_many([ 'foo', 'bar' ], :spam)
      SpamClassifier::Words.class_variable_get("@@cache")['word::bar'][:spam].should == 1.0
    end
    it "increments the spam/ham count for a given key to the data source" do
      SpamClassifier::Words.increment_many([ 'foo', 'bar' ], :spam)
      SpamClassifier::Words.write!
      SpamClassifier::Words.find_by_key('word::foo')[:spam].should == 1
      SpamClassifier::Words.find_by_key('word::foo')[:ham].should == 0

      # unless the cache has been written -> increment the cache but not the store,
      # once we wrote the cache to the store -> well.. increment the store:
      SpamClassifier::Words.increment_many([ 'foo' ], :spam)
      SpamClassifier::Words.find_by_key('word::foo')[:spam].should == 1
      SpamClassifier::Words.write!
      SpamClassifier::Words.find_by_key('word::foo')[:spam].should == 2

      # and again for the other category..
      SpamClassifier::Words.find_by_key('word::foo')[:ham].should == 0
      SpamClassifier::Words.increment_many([ 'foo' ], :ham)
      SpamClassifier::Words.find_by_key('word::foo')[:ham].should == 0
      SpamClassifier::Words.write!
      SpamClassifier::Words.find_by_key('word::foo')[:ham].should == 1
    end
  end

end