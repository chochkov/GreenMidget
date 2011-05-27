# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'spec_helper'

describe GreenMidget::Words do
  include GreenMidget

  before(:each) do
    GreenMidgetRecords.delete_all
  end

  describe "self.record_keys" do
    it "takes an array of words and optionally a category, returns an array of corresponding record keys wrt category" do
      Words.record_keys([ 'one' ]).should == [ "#{ Words.prefix }one::#{ NULL }_count", "#{ Words.prefix }one::#{ ALTERNATIVE }_count" ]
      Words.record_keys([ 'one' ], NULL).should == [ "#{ Words.prefix }one::#{ NULL }_count" ]
    end
  end

  describe "#probability_for" do
    it "should return the smoother constant if the word has zero examples" do
      GreenMidgetRecords[Words['word'].record_key(ALTERNATIVE)].should == ''
    end
  end
end
