# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'spec_helper'

include GreenMidget

describe UrlDetection do
  it 'should not detect a url' do
    UrlDetection.new('not a url').any?.should_not be_true
  end

  it 'should detect a url' do
    UrlDetection.new('http://foo.de/').any?.should be_true
  end
end
