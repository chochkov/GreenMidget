require 'spec_helper'

describe SpamClassifier::Features do

  before(:each) do
    SpamClassifier::SpamClassificationIndex.delete_all
    SpamClassifier::FEATURES.concat(%w(notfound new existing))
    SpamClassifier::Features['existing']
    SpamClassifier::SpamClassificationIndex.write!
    SpamClassifier::SpamClassificationIndex.class_eval{ @@cache = {} }
  end

  describe "#[]()" do
    it "should raise an error if given an non-existing feature" do
      lambda do
        SpamClassifier::Features['wrong']
      end.should raise_error(ArgumentError)
    end
    it "should first look in the cache and take the value from there if it exists" do
      SpamClassifier::SpamClassificationIndex.fetch_all
      SpamClassifier::Features.find_by_key('feature::notfound').should == nil
      SpamClassifier::Features['notfound'].should_not == nil
    end
    it "should take Features from data store if not found in the cache" do
      SpamClassifier::Features.create!('feature::notfound')
      SpamClassifier::Features.find_by_key('feature::notfound').should_not == nil
      SpamClassifier::Features['notfound'].should == SpamClassifier::Features.find_by_key('feature::notfound')
    end
    it "should create new object if no key found in the datastore and add to the cache" do
      SpamClassifier::Features.find_by_key('feature::notfound').should == nil
    end
  end

  describe "#probability_for" do
    it "should return Feature[feature] / TrainingExamples[feature]" do
      SpamClassifier::Features['url_in_text'].update_attributes({ :spam_count => 10, :ham_count => 20 })
      item = SpamClassifier::TrainingExamples.create!('training_examples_with_feature::url_in_text')
      item.update_attributes({ :spam_count => 100, :ham_count => 1000 })
      SpamClassifier::SpamClassificationIndex.write!
      SpamClassifier::Features['url_in_text'].probability_for(:spam).should == 10.0/100
      SpamClassifier::Features['url_in_text'].probability_for(:ham).should  == 20.0/1000
    end
  end

end
