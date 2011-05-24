# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'spec_helper'

describe GreenMidget::Features do
  include GreenMidget

  before(:each) do
    GreenMidgetRecords.delete_all
    GreenMidgetRecords.class_variable_set("@@cache", {})
  end

  describe "#probability_for" do
    it "should return Feature[feature] / Examples[feature]" do
      GreenMidgetRecords.create(:key => Features["url_in_text"].record_key(NULL),        :value => 20  )
      GreenMidgetRecords.create(:key => Features["url_in_text"].record_key(ALTERNATIVE), :value => 10  )

      GreenMidgetRecords.create(:key => Examples['url_in_text'].record_key(NULL),        :value => 100 )
      GreenMidgetRecords.create(:key => Examples['url_in_text'].record_key(ALTERNATIVE), :value => 1000)

      Features['url_in_text'].probability_for(NULL).should == 20.0/100
      Features['url_in_text'].probability_for(ALTERNATIVE).should  == 10.0/1000
    end
  end
end
