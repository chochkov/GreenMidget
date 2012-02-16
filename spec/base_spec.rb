# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'spec_helper'
require 'tester'

describe GreenMidget::Base do
  include GreenMidget

  before(:each) do
    Records.delete_all
    [
      {:key => "#{ Words.prefix    }this::#{          ALTERNATIVE  }_count", :value => 701  },
      {:key => "#{ Words.prefix    }this::#{          NULL         }_count", :value => 11   },
      {:key => "#{ Words.prefix    }test::#{          ALTERNATIVE  }_count", :value => 9    },
      {:key => "#{ Words.prefix    }test::#{          NULL         }_count", :value => 71   },
      {:key => "#{ Words.prefix    }goes::#{          ALTERNATIVE  }_count", :value => 90   },
      {:key => "#{ Words.prefix    }goes::#{          NULL         }_count", :value => 90   },
      {:key => "#{ Words.prefix    }rid::#{           ALTERNATIVE  }_count", :value => 311  },
      {:key => "#{ Words.prefix    }rid::#{           NULL         }_count", :value => 290  },
      {:key => "#{ Words.prefix    }dirty::#{         ALTERNATIVE  }_count", :value => 222  },
      {:key => "#{ Words.prefix    }dirty::#{         NULL         }_count", :value => 45   },
      {:key => "#{ Words.prefix    }spam::#{          ALTERNATIVE  }_count", :value => 11   },
      {:key => "#{ Words.prefix    }spam::#{          NULL         }_count", :value => 133  },
      {:key => "#{ Words.prefix    }words::#{         ALTERNATIVE  }_count", :value => 6    },
      {:key => "#{ Words.prefix    }words::#{         NULL         }_count", :value => 811  },
      {:key => "#{ Words.prefix    }zero::#{          ALTERNATIVE  }_count", :value => 0    },
      {:key => "#{ Words.prefix    }zero::#{          NULL         }_count", :value => 0    },
      {:key => "#{ Features.prefix }url_in_text::#{   ALTERNATIVE  }_count", :value => 440  },
      {:key => "#{ Features.prefix }url_in_text::#{   NULL         }_count", :value => 40   },
      {:key => "#{ Features.prefix }email_in_text::#{ ALTERNATIVE  }_count", :value => 112  },
      {:key => "#{ Features.prefix }email_in_text::#{ NULL         }_count", :value => 9    },
      {:key => "#{ Examples.prefix }any::#{           ALTERNATIVE  }_count", :value => 1000 },
      {:key => "#{ Examples.prefix }any::#{           NULL         }_count", :value => 1000 },
      {:key => "#{ Examples.prefix }url_in_text::#{   ALTERNATIVE  }_count", :value => 1000 },
      {:key => "#{ Examples.prefix }url_in_text::#{   NULL         }_count", :value => 1000 },
      {:key => "#{ Examples.prefix }email_in_text::#{ ALTERNATIVE  }_count", :value => 1000 },
      {:key => "#{ Examples.prefix }email_in_text::#{ NULL         }_count", :value => 1000 },
    ].each do |entry|
      Records.create(entry)
    end
  end

  describe "#log_ratio" do
    it "should be for 'this words'" do
      Tester.new('this words').log_ratio.should == Math::log((701.0/1000) / (11.0/1000)) + Math::log((6.0/1000) / (811.0/1000)) + Math::log((1000.0/2000) / (1000.0/2000))
    end

    it "should be smaller for a smaller number of spammy words" do
      Tester.new('this dirty test').log_ratio.should > Tester.new('this test').log_ratio
    end

    it "considers 'test goes words' ham" do
      Tester.new('test goes words').log_ratio.should < REJECT_ALTERNATIVE_MAX
    end

    it "considers 'rid goes dirty' spam" do
      Tester.new('rid goes dirty').log_ratio.should >= ACCEPT_ALTERNATIVE_MIN
    end

    it "doesn't know whether 'zero goes rid' is spam or not" do
      Tester.new('zero goes rid').log_ratio.between?(REJECT_ALTERNATIVE_MAX, ACCEPT_ALTERNATIVE_MIN).should be_true
    end

    it "thinks of 'test boss@offshore.com' as more spam than just 'test'" do
      Tester.new('test boss@offshore.com').log_ratio.
        should > Tester.new('test').log_ratio
    end

    it "thinks of 'test www.offshore.com' as more spam than just 'test'" do
      Tester.new('test www.offshore.com').log_ratio.
        should > Tester.new('test').log_ratio
    end

    it "will tolerate urls coming from known sites" do
      Tester.new('test www.offshore.com').log_ratio.should >
      Tester.new('test www.soundcloud.com').log_ratio
    end

    it "should say DUNNO if it doesnt have neither ALTERNATIVE nor NULL score for a message" do
      Tester.new('zero newword heuristicspass').log_ratio.between?(REJECT_ALTERNATIVE_MAX, ACCEPT_ALTERNATIVE_MIN).should be_true
    end

    it "should say ALTERNATIVE if it has spam score for a message and doesn't have ham score for it" do
      a = Tester.new('nosuchword nowordsuch heuristicspass')
      a.log_ratio.between?(REJECT_ALTERNATIVE_MAX, ACCEPT_ALTERNATIVE_MIN).should be_true
      a.classify_as!(ALTERNATIVE)
      a.log_ratio.should >= ACCEPT_ALTERNATIVE_MIN
    end

    it "should say NULL if it has ham score for a message and doesn't have spam score for it" do
      a = Tester.new('suchwordno nowordsuch heuristicspasss')
      a.log_ratio.between?(REJECT_ALTERNATIVE_MAX, ACCEPT_ALTERNATIVE_MIN).should be_true
      a.classify_as!(NULL)
      a.log_ratio.should < REJECT_ALTERNATIVE_MAX
    end
  end

  describe "#classify" do
    it "should add unknown words to the dictionary before classification" do
      Tester.new('newword needs to pass heuristics').classify
      Words['newword'][ALTERNATIVE].should == 0
      Words['newword'][ALTERNATIVE].should == 0
    end
  end

  describe "#classify_as!" do
    it "should increase the index counts of the classified words" do
      lambda {
        Tester.new('zero').classify_as!(NULL)
      }.should change { Records.find_by_key(Words['zero'].record_key(NULL)).value.to_f }.by(1)
    end

    it "should increment the learning examples count for all features" do
      FEATURES.each do |feature|
        lambda {
          Tester.new('zero').classify_as!(NULL)
        }.should change { Records.find_by_key(Examples[feature].record_key(NULL)).value.to_f }.by(1)
      end
    end

    it "should not add new records for known keys" do
      a = Tester.new 'stuff unknown sofar'

      lambda {
        a.classify_as! ALTERNATIVE
      }.should change { Records.count }.by(3)

      lambda {
        a.classify_as! ALTERNATIVE
      }.should_not change { Records.count }
    end
  end

  describe "#words" do
    it "should ignore words less than 3 characters" do
      Tester.new('is 2 ch').words.should == []
    end

    it "should break large character strings into chunks of 20 bytes" do
      Tester.new('s'*20 + '111').words.should == ['s'*20, '111']
    end

    it "should bring uppercase to lowcase" do
      Tester.new('HOWBIG').words.should == ['howbig']
    end

    it "should not consider parts of email address as individual words" do
      Tester.new('friend@soundcloud.com').words.should == []
    end

    it "should not consider parts of website url as individual words" do
      Tester.new('www.myguy.com http://weargeil.org').words.should == []
    end
  end

  # describe "extreme cases" do
  #   it "should fallback to training_examples_with_feature::any if there're no examples in the database for a particular feature" do
  #     # a new feature should be added with no examples and make sure the classifier won't break
  #     pending('todo')
  #   end
  #   it "throw an exception if no training examples were given, but it's asked for classification" do
  #     # if Records.count(ALTERNATIVE) or Records.count(NULL) is 0.0 => throw an exception
  #     pending('todo')
  #   end
  # end
  #
  # describe "#feature_present?" do
  #   it "should throw NoMethodError if a feature look-up method has not been implemented" do
  #     pending('')
  #   end
  # end
end
