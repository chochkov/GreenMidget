# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'spec_helper'

describe SpamClassifier::TrainingExamples do
  include SpamClassifier

  before(:each) do
    TrainingExamples.delete_all
    TrainingExamples.class_variable_set("@@cache", {})
  end

  describe "#[]()" do
    before do
      @call_any = lambda do
        TrainingExamples['any']
      end
    end

    it "should return training_examples_with_feature::any if passed a (new) feature key that has no examples yet" do
      record_any = TrainingExamples.create!(TrainingExamples::PREFIX + "any")
      record_any.update_attributes({:spam_count => 1000, :ham_count => 1000})
      TrainingExamples.find_by_key(TrainingExamples::PREFIX + "new").should == nil
      TrainingExamples['new'][:spam].should == record_any[:spam]
      TrainingExamples['new'][:ham].should  == record_any[:ham]
    end

    it "should return the feature's own example counts if these exist" do
      TrainingExamples.create!(TrainingExamples::PREFIX + "new")
      TrainingExamples.find_by_key(TrainingExamples::PREFIX + 'new').update_attributes({ :spam_count => 1, :ham_count => 3 })
      TrainingExamples['new'][:spam].should == 1
      TrainingExamples['new'][:ham].should  == 3
    end

    it "should throw an error if training_examples_with_feature::any isn't found" do
      @call_any.should raise_error(ZeroDivisionError)
    end

    it "should throw an error if training_examples_with_feature::any has a zero spam_count and ham_count" do
      TrainingExamples.create!(TrainingExamples::PREFIX + "any")
      @call_any.should raise_error(ZeroDivisionError)
    end

    it "should throw an error if training_examples_with_feature::any has a zero spam_count or ham_count" do
      TrainingExamples.create!(TrainingExamples::PREFIX + "any")
      TrainingExamples.find_by_key(TrainingExamples::PREFIX + "any").update_attributes({ :spam_count => 0, :ham_count => 1 })
      @call_any.should raise_error(ZeroDivisionError)
    end

    it "should not throw an error if both columns are positive" do
      TrainingExamples.create!(TrainingExamples::PREFIX + "any")
      TrainingExamples.find_by_key(TrainingExamples::PREFIX + "any").update_attributes({ :spam_count => 1, :ham_count => 1 })
      @call_any.should_not raise_error(ZeroDivisionError)
    end
  end

  describe "#probability_for" do
    it "should return the probability of a feature falling into category as: TrainingExamples[feature][category] / (TrainingExamples[feature][:spam] + TrainingExamples[feature][:ham])" do
      TrainingExamples.create!(TrainingExamples::PREFIX + "url_in_text").update_attributes({:spam_count => 150, :ham_count => 1000})
      TrainingExamples['url_in_text'].probability_for(:spam).should == 150.0/(1000 + 150)
    end
  end

  describe "#no_examples?" do
    before(:each) do
      @record = TrainingExamples.create!(TrainingExamples::PREFIX + "url_in_text")
    end

    it "should return true if spam_count and ham_count are zero" do
      @record.no_examples?.should be_true
    end

    it "should return true if spam_count or ham_count are zero" do
      @record.update_attributes({ :spam_count => 1 })
      @record.no_examples?.should be_true
    end

    it "should should return false if both spam_count and ham_count are positive" do
      @record.update_attributes({ :spam_count => 1, :ham_count => 1 })
      @record.no_examples?.should be_false
    end
  end
end
