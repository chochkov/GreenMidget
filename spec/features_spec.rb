# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'spec_helper'

describe GreenMidget::Features do
  include GreenMidget

  before(:each) do
    GreenMidgetRecords.delete_all
    GreenMidgetRecords.class_variable_set("@@cache", {})
  end

  describe "#probability_for" do
    it "should return Feature[feature] / TrainingExamples[feature]" do
      GreenMidgetRecords.create(Features["url_in_text"].record_key(CATEGORIES.first)).update_attribute(:value, 20)
      GreenMidgetRecords.create(Features["url_in_text"].record_key(CATEGORIES.last)).update_attribute(:value, 10)

      GreenMidgetRecords.create(Examples['url_in_text'].record_key(CATEGORIES.first)).update_attribute(:value, 100)
      GreenMidgetRecords.create(Examples['url_in_text'].record_key(CATEGORIES.last)).update_attribute(:value, 1000)

      Features['url_in_text'].probability_for(CATEGORIES.first).should == 20.0/100
      Features['url_in_text'].probability_for(CATEGORIES.last).should  == 10.0/1000
    end
  end
end
