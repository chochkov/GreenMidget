require 'spec_helper'

describe SpamClassifier::SpamClassificationIndex do
  before(:each) do
    SpamClassifier::SpamClassificationIndex.delete_all
  end

  describe "#fetch_all" do
    it "should empty cache before fetching" do
      SpamClassifier::SpamClassificationIndex.fetch_all([ 'foo', 'bar' ])
      SpamClassifier::SpamClassificationIndex.class_variable_get("@@cache")['bar'].should_not == nil
      SpamClassifier::SpamClassificationIndex.fetch_all(['foo', 'newbar'])
      SpamClassifier::SpamClassificationIndex.class_variable_get("@@cache")['bar'].should == nil
    end
    it "does a multi get on all words and keys" do
      cache = SpamClassifier::SpamClassificationIndex.fetch_all([ 'foo', 'bar' ])
      cache['foo'].should.eql? SpamClassifier::SpamClassificationIndex.class_eval{new('foo')}
    end
    it "should fetch the system keys along with the given words" do
      SpamClassifier::TrainingExamples.create!('training_examples_with_feature::words')
      SpamClassifier::SpamClassificationIndex.fetch_all([])
      cache = SpamClassifier::SpamClassificationIndex.class_variable_get("@@cache")
      cache['training_examples_with_feature::words'].should_not == nil
      cache.count.should == 1
    end
    it "the cache should be a hash; its keys should be strings" do
      SpamClassifier::TrainingExamples.create!('training_examples_with_feature::words')
      SpamClassifier::Features.create!('feature::url_in_text')
      SpamClassifier::Words.create!('oneword')
      SpamClassifier::SpamClassificationIndex.fetch_all([ 'oneword' ])
      cache = SpamClassifier::SpamClassificationIndex.class_variable_get("@@cache")
      cache.class.should.eql? Hash
      cache.count.should == 3
      cache.keys.each do |key|
        key.class.should.eql? String
      end
    end
    it "should touch the data store only once per request" do
      pending('find a way to assert this - in the new refactoring it should touch it exactly three times!')
      # SpamClassifier::SpamClassificationIndex.create!('word')
      # SpamClassifier::SpamClassificationIndex.create!('other')
      # SpamClassifier::SpamClassificationIndex.fetch_all([ 'word', 'other' ])
    end
  end

  describe "#increment" do
    it "should increment counts first in cache and write! to store only if explicitly called" do
      lambda {
        SpamClassifier::SpamClassificationIndex['stuff'].increment(:spam)
      }.should change { SpamClassifier::SpamClassificationIndex['stuff'][:spam] }.by(1)

      SpamClassifier::SpamClassificationIndex.write!

      lambda {
        SpamClassifier::SpamClassificationIndex['stuff'].increment(:spam)
      }.should_not change { SpamClassifier::SpamClassificationIndex.find_by_key('stuff')[:spam] }
    end
  end

end
