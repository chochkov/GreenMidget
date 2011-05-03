require 'spec_helper'

describe SpamClassifier::SpamClassificationIndex do
  include SpamClassifier

  before(:each) do
    SpamClassificationIndex.delete_all
  end

  describe "#fetch_all" do
    it "should empty cache before fetching" do
      SpamClassificationIndex.fetch_all([ 'foo', 'bar' ])
      SpamClassificationIndex.class_variable_get("@@cache")['bar'].should_not == nil
      SpamClassificationIndex.fetch_all(['foo', 'newbar'])
      SpamClassificationIndex.class_variable_get("@@cache")['bar'].should == nil
    end

    it "does a multi get on all words and keys" do
      cache = SpamClassificationIndex.fetch_all([ 'foo', 'bar' ])
      cache['foo'].should.eql? SpamClassificationIndex.class_eval{new('foo')}
    end

    it "should fetch the system keys along with the given words" do
      TrainingExamples.create!('training_examples_with_feature::any')
      SpamClassificationIndex.fetch_all([])
      cache = SpamClassificationIndex.class_variable_get("@@cache")
      cache['training_examples_with_feature::any'].should_not == nil
      cache.count.should == 1
    end

    it "the cache should be a hash; its keys should be strings" do
      TrainingExamples.create!('training_examples_with_feature::any')
      Features.create!('with_feature::url_in_text')
      Words.create!('oneword')
      SpamClassificationIndex.fetch_all([ 'oneword' ])
      cache = SpamClassificationIndex.class_variable_get("@@cache")
      cache.class.should.eql? Hash
      cache.count.should == 3
      cache.keys.each do |key|
        key.class.should.eql? String
      end
    end

    it "should touch the data store only once per request" do
      pending('find a way to assert this - in the new refactoring it should touch it exactly three times!')
      # SpamClassificationIndex.create!('word')
      # SpamClassificationIndex.create!('other')
      # SpamClassificationIndex.fetch_all([ 'word', 'other' ])
    end
  end

  describe "#increment" do
    it "should increment counts first in cache and write! to store only if explicitly called" do
      lambda {
        SpamClassificationIndex['stuff'].increment(:spam)
      }.should change { SpamClassificationIndex['stuff'][:spam] }.by(1)

      SpamClassificationIndex.write!

      lambda {
        SpamClassificationIndex['stuff'].increment(:spam)
      }.should_not change { SpamClassificationIndex.find_by_key('stuff')[:spam] }
    end
  end

end
