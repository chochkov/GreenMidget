require 'spec_helper'

describe Features do

  before(:each) do
    SpamClassificationIndex.delete_all
    SpamClassifier::FEATURES.concat(%w(notfound new existing))
    Features['existing']
    SpamClassificationIndex.write!
    SpamClassificationIndex.class_eval{ @@cache = {} }
  end

  describe "#[]()" do
    it "should raise an error if given an non-existing feature" do
      lambda do
        Features['wrong']
      end.should raise_error(ArgumentError)
    end
    it "should first look in the cache and take the value from there if it exists" do
      SpamClassificationIndex.fetch_all
      Features.find_by_key('feature::notfound').should == nil
      Features['notfound'].should_not == nil
    end
    it "should take Features from data store if not found in the cache" do
      Features.create!('feature::notfound')
      Features.find_by_key('feature::notfound').should_not == nil
      Features['notfound'].should == Features.find_by_key('feature::notfound')
    end
    it "should create new object if no key found in the datastore and add to the cache" do
      Features['notfound'].should.eql? Features.class_eval{ new('feature::notfound') }
      Features.find_by_key('feature::notfound').should == nil
    end
  end

  describe "#probability_for" do
    it "should return Feature[feature] / TrainingExamples[feature]" do
      Features['url_in_text'].update_attributes({ :spam_count => 10, :ham_count => 20 })
      item = TrainingExamples.create!('training_examples_with_feature::url_in_text')
      item.update_attributes({ :spam_count => 100, :ham_count => 1000 })
      SpamClassificationIndex.write!
      Features['url_in_text'].probability_for(:spam).should == 10.0/100
      Features['url_in_text'].probability_for(:ham).should  == 20.0/1000
    end
  end

end
