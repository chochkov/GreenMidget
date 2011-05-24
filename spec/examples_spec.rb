# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'spec_helper'

describe GreenMidget::Examples do
  include GreenMidget

  before(:each) do
    GreenMidgetRecords.delete_all
    GreenMidgetRecords.class_variable_set("@@cache", {})
  end

  describe "#[]()" do
    before do
      @call_any = lambda do
        Examples[Examples::GENERAL_FEATURE_NAME]
      end
    end

    it "should return the general feature examples if passed a (new) feature key that has no examples yet" do
      GreenMidgetRecords.create(Examples.prefix + Examples::GENERAL_FEATURE_NAME + "::#{ NULL }_count").update_attribute(:value, 1000)
      GreenMidgetRecords.create(Examples.prefix + Examples::GENERAL_FEATURE_NAME + "::#{ ALTERNATIVE }_count").update_attribute(:value, 1000)
      GreenMidgetRecords.find_by_key(Examples.prefix + "new::#{ NULL }_count").should == nil
      GreenMidgetRecords.fetch_all
      CATEGORIES.each do |category|
        Examples['new'][category].should == Examples[Examples::GENERAL_FEATURE_NAME][category]
      end
    end
    it "should return the feature's own example counts if these exist" do
      GreenMidgetRecords.create(Examples.prefix + "new::#{ NULL }_count").update_attribute(:value, 3)
      GreenMidgetRecords.create(Examples.prefix + "new::#{ ALTERNATIVE }_count").update_attribute(:value, 1)
      Examples['new'][NULL].should  == 3
    end

    it "should throw an error if the general feature examples isn't found" do
      @call_any.should raise_error
    end

    it "should throw an error if the general feature examples has a zero spam_count and ham_count" do
      GreenMidgetRecords.create(Examples.prefix + "#{ Examples::GENERAL_FEATURE_NAME }::#{ NULL }_count")
      @call_any.should raise_error
    end

    it "should throw an error if the general feature examples has a zero spam_count or ham_count" do
      GreenMidgetRecords.create(Examples.prefix + "#{ Examples::GENERAL_FEATURE_NAME }::#{ NULL }_count").update_attribute(:value, 0)
      @call_any.should raise_error
    end

    it "should not throw an error if both columns are positive" do
      GreenMidgetRecords.create(Examples.prefix + "#{ Examples::GENERAL_FEATURE_NAME }::#{ NULL }_count").update_attribute(:value, 2)
      GreenMidgetRecords.create(Examples.prefix + "#{ Examples::GENERAL_FEATURE_NAME }::#{ ALTERNATIVE }_count").update_attribute(:value, 1)
      @call_any.should_not raise_error
    end
  end

  describe "#probability_for" do
    it "should return the probability of a feature falling into category as: Examples[feature][category] / (Examples[feature][ALTERNATIVE] + Examples[feature][NULL])" do
      GreenMidgetRecords.create(Examples['url_in_text'].record_key(NULL)).update_attribute(:value, 1000)
      GreenMidgetRecords.create(Examples['url_in_text'].record_key(ALTERNATIVE)).update_attribute(:value, 150)
      Examples['url_in_text'].probability_for(ALTERNATIVE).should == 150.0/(1000 + 150)
    end
  end

  describe "#no_examples?" do
    before(:each) do
      GreenMidgetRecords.create(Examples['url_in_text'].record_key(ALTERNATIVE))
      GreenMidgetRecords.create(Examples['url_in_text'].record_key(NULL))
      @object = Examples['url_in_text']
    end

    it "should return true if spam_count and ham_count are zero" do
      @object.no_examples?.should be_true
    end

    it "should return true if spam_count or ham_count are zero" do
      GreenMidgetRecords.find_by_key(@object.record_key(NULL)).update_attribute(:value, 1)
      @object.no_examples?.should be_true
    end

    it "should should return false if both spam_count and ham_count are positive" do
      GreenMidgetRecords.find_by_key(@object.record_key(NULL)).update_attribute(:value, 1)
      GreenMidgetRecords.find_by_key(@object.record_key(ALTERNATIVE)).update_attribute(:value, 1)
      @object.no_examples?.should be_false
    end
  end
end
