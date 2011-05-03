require 'spec_helper'

describe SpamClassifier::Features do
  include SpamClassifier

  before(:each) do
    Features.delete_all
    Features.class_variable_set("@@cache", {})
  end

  describe "#[]()" do
    it "should first look in the cache and take the value from there if it exists" do
      SpamClassificationIndex.fetch_all
      Features.find_by_key('with_feature::notfound').should == nil
      Features['notfound'].should_not == nil
    end

    it "should take Features from data store if not found in the cache" do
      Features.create!('with_feature::notfound')
      Features.find_by_key('with_feature::notfound').should_not == nil
      Features['notfound'].should == Features.find_by_key('with_feature::notfound')
    end

    it "should create new object if no key found in the datastore and add to the cache" do
      Features.find_by_key('with_feature::notfound').should == nil
    end
  end

  describe "#probability_for" do
    it "should return Feature[feature] / TrainingExamples[feature]" do
      features = Features.create!('with_feature::url_in_text')
      features.update_attributes({ :spam_count => 10, :ham_count => 20 })
      Features['url_in_text'][:spam].should == 10

      examples = TrainingExamples.create!('training_examples_with_feature::url_in_text')
      examples.update_attributes({ :spam_count => 100, :ham_count => 1000 })

      TrainingExamples['url_in_text'][:spam].should == 100

      # SpamClassificationIndex.write!
      Features['url_in_text'].probability_for(:spam).should == 10.0/100
      # Features['url_in_text'].probability_for(:ham).should  == 20.0/1000
    end
  end

end
