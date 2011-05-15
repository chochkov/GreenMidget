# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'spec_helper'

describe SpamClassifier::Examples do
  include SpamClassifier

  before(:each) do
    Examples.delete_all
    Examples.class_variable_set("@@cache", {})
  end

  # describe "#[]()" do
  #   before do
  #     @call_any = lambda do
  #       Examples['any']
  #     end
  #   end
  # 
  #   it "should return training_examples_with_feature::any if passed a (new) feature key that has no examples yet" do
  #     record_any = Examples.create!(Examples::PREFIX + "any")
  #     record_any.update_attributes({:spam_count => 1000, :ham_count => 1000})
  #     Examples.find_by_key(Examples::PREFIX + "new").should == nil
  #     Examples['new'][:spam].should == record_any[:spam]
  #     Examples['new'][:ham].should  == record_any[:ham]
  #   end
  # 
  #   it "should return the feature's own example counts if these exist" do
  #     Examples.create!(Examples::PREFIX + "new")
  #     Examples.find_by_key(Examples::PREFIX + 'new').update_attributes({ :spam_count => 1, :ham_count => 3 })
  #     Examples['new'][:spam].should == 1
  #     Examples['new'][:ham].should  == 3
  #   end
  # 
  #   it "should throw an error if training_examples_with_feature::any isn't found" do
  #     @call_any.should raise_error(ZeroDivisionError)
  #   end
  # 
  #   it "should throw an error if training_examples_with_feature::any has a zero spam_count and ham_count" do
  #     Examples.create!(Examples::PREFIX + "any")
  #     @call_any.should raise_error(ZeroDivisionError)
  #   end
  # 
  #   it "should throw an error if training_examples_with_feature::any has a zero spam_count or ham_count" do
  #     Examples.create!(Examples::PREFIX + "any")
  #     Examples.find_by_key(Examples::PREFIX + "any").update_attributes({ :spam_count => 0, :ham_count => 1 })
  #     @call_any.should raise_error(ZeroDivisionError)
  #   end
  # 
  #   it "should not throw an error if both columns are positive" do
  #     Examples.create!(Examples::PREFIX + "any")
  #     Examples.find_by_key(Examples::PREFIX + "any").update_attributes({ :spam_count => 1, :ham_count => 1 })
  #     @call_any.should_not raise_error(ZeroDivisionError)
  #   end
  # end
  # 
  # describe "#probability_for" do
  #   it "should return the probability of a feature falling into category as: Examples[feature][category] / (Examples[feature][:spam] + Examples[feature][:ham])" do
  #     Examples.create!(Examples::PREFIX + "url_in_text").update_attributes({:spam_count => 150, :ham_count => 1000})
  #     Examples['url_in_text'].probability_for(:spam).should == 150.0/(1000 + 150)
  #   end
  # end
  # 
  # describe "#no_examples?" do
  #   before(:each) do
  #     @record = Examples.create!(Examples::PREFIX + "url_in_text")
  #   end
  # 
  #   it "should return true if spam_count and ham_count are zero" do
  #     @record.no_examples?.should be_true
  #   end
  # 
  #   it "should return true if spam_count or ham_count are zero" do
  #     @record.update_attributes({ :spam_count => 1 })
  #     @record.no_examples?.should be_true
  #   end
  # 
  #   it "should should return false if both spam_count and ham_count are positive" do
  #     @record.update_attributes({ :spam_count => 1, :ham_count => 1 })
  #     @record.no_examples?.should be_false
  #   end
  # end
end
