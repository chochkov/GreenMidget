# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'spec_helper'

describe GreenMidget::Words do
  include GreenMidget

  before(:each) do
    GreenMidgetRecords.delete_all
  end

  describe "self.record_keys" do
    it "takes an array of words and optionally a category, returns an array of corresponding record keys wrt category" do
      Words.record_keys([ 'one' ]).should == [ "#{ Words.prefix }one::ham_count", "#{ Words.prefix }one::spam_count" ]
      Words.record_keys([ 'one' ], CATEGORIES.first).should == [ "#{ Words.prefix }one::#{ CATEGORIES.first }_count" ]
    end
  end
end
