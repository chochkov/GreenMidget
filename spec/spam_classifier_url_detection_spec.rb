require 'spec_helper'

require File.expand_path('../../lib/spam_classifier', __FILE__);

module SpamClassifier
  describe UrlDetection do
    it 'should not detect a url' do
      UrlDetection.new('not a url').any?.should_not be_true
    end

    it 'should detect a url' do
      UrlDetection.new('http://foo.de/').any?.should be_true
    end
  end
end
