# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
require 'spec_helper'
require File.join(File.dirname(__FILE__), 'tester')

describe GreenMidget::Base do
  include GreenMidget

  before(:each) do
    GreenMidgetRecords.delete_all
    [
      {:key => "#{ Words::PREFIX    }this::#{          CATEGORIES.last  }_count", :value => 701  },
      {:key => "#{ Words::PREFIX    }this::#{          CATEGORIES.first }_count", :value => 11   },
      {:key => "#{ Words::PREFIX    }test::#{          CATEGORIES.last  }_count", :value => 9    },
      {:key => "#{ Words::PREFIX    }test::#{          CATEGORIES.first }_count", :value => 71   },
      {:key => "#{ Words::PREFIX    }goes::#{          CATEGORIES.last  }_count", :value => 90   },
      {:key => "#{ Words::PREFIX    }goes::#{          CATEGORIES.first }_count", :value => 90   },
      {:key => "#{ Words::PREFIX    }rid::#{           CATEGORIES.last  }_count", :value => 311  },
      {:key => "#{ Words::PREFIX    }rid::#{           CATEGORIES.first }_count", :value => 290  },
      {:key => "#{ Words::PREFIX    }dirty::#{         CATEGORIES.last  }_count", :value => 222  },
      {:key => "#{ Words::PREFIX    }dirty::#{         CATEGORIES.first }_count", :value => 45   },
      {:key => "#{ Words::PREFIX    }spam::#{          CATEGORIES.last  }_count", :value => 11   },
      {:key => "#{ Words::PREFIX    }spam::#{          CATEGORIES.first }_count", :value => 133  },
      {:key => "#{ Words::PREFIX    }words::#{         CATEGORIES.last  }_count", :value => 6    },
      {:key => "#{ Words::PREFIX    }words::#{         CATEGORIES.first }_count", :value => 811  },
      {:key => "#{ Words::PREFIX    }zero::#{          CATEGORIES.last  }_count", :value => 0    },
      {:key => "#{ Words::PREFIX    }zero::#{          CATEGORIES.first }_count", :value => 0    },
      {:key => "#{ Features::PREFIX }url_in_text::#{   CATEGORIES.last  }_count", :value => 440  },
      {:key => "#{ Features::PREFIX }url_in_text::#{   CATEGORIES.first }_count", :value => 40   },
      {:key => "#{ Features::PREFIX }email_in_text::#{ CATEGORIES.last  }_count", :value => 112  },
      {:key => "#{ Features::PREFIX }email_in_text::#{ CATEGORIES.first }_count", :value => 9    },
      {:key => "#{ Examples::PREFIX }any::#{           CATEGORIES.last  }_count", :value => 1000 },
      {:key => "#{ Examples::PREFIX }any::#{           CATEGORIES.first }_count", :value => 1000 },
      {:key => "#{ Examples::PREFIX }url_in_text::#{   CATEGORIES.last  }_count", :value => 1000 },
      {:key => "#{ Examples::PREFIX }url_in_text::#{   CATEGORIES.first }_count", :value => 1000 },
      {:key => "#{ Examples::PREFIX }email_in_text::#{ CATEGORIES.last  }_count", :value => 1000 },
      {:key => "#{ Examples::PREFIX }email_in_text::#{ CATEGORIES.first }_count", :value => 1000 },
    ].each do |entry|
      GreenMidgetRecords.create!(entry[:key]).update_attribute(:value, entry[:value])
    end
  end

  it "should calculate spam probability of 2.43e-06 for 'test goes words'" do
    Tester.new('test goes words').log_probability(:spam).round(5).
      should == Math::log(9.0/1000 * 90.0/1000 * 6.0/1000 * 1000.0/(1000+1000)).round(5)
  end

  it "should calculate ham probability of 0.00259 for 'test goes words'" do
    Tester.new('test goes words').log_probability(:ham).round(5).
      should == Math::log(71.0/1000 * 90.0/1000 * 811.0/1000 * 1000.0/(1000+1000)).round(5)
  end

  describe 'GreenMidgetProbabilities#bayesian_factor' do
    it "should be smaller for a smaller number of spammy words" do
      Tester.new('this dirty test').bayesian_factor.should > Tester.new('this test').bayesian_factor
    end
  end

  describe "#bayesian_factor" do
    it "should add unknown words to the dictionary before classification" do
      Tester.new('newword needs to pass heuristics').classify
      Words['newword'][:spam].should == 0
      Words['newword'][:spam].should == 0
    end

    it "considers 'test goes words' ham" do
      Tester.new('test goes words').bayesian_factor.should < REJECT_ALTERNATIVE_MAX
    end

    it "considers 'rid goes dirty' spam" do
      Tester.new('rid goes dirty').bayesian_factor.should >= ACCEPT_ALTERNATIVE_MIN
    end

    it "doesn't know whether 'zero goes rid' is spam or not" do
      Tester.new('zero goes rid').bayesian_factor.between?(REJECT_ALTERNATIVE_MAX, ACCEPT_ALTERNATIVE_MIN).should be_true
    end

    it "thinks of 'test boss@offshore.com' as more spam than just 'test'" do
      Tester.new('test boss@offshore.com').bayesian_factor.
        should > Tester.new('test').bayesian_factor
    end

    it "thinks of 'test www.offshore.com' as more spam than just 'test'" do
      Tester.new('test www.offshore.com').bayesian_factor.
        should > Tester.new('test').bayesian_factor
    end

    it "will tolerate urls coming from known sites" do
      Tester.new('test www.offshore.com').bayesian_factor.should >
      Tester.new('test www.soundcloud.com').bayesian_factor
    end

    it "should say DUNNO if it doesnt have neither :spam nor :ham score for a message" do
      Tester.new('zero newword heuristicspass').bayesian_factor.between?(REJECT_ALTERNATIVE_MAX, ACCEPT_ALTERNATIVE_MIN).should be_true
    end

    it "should say ALTERNATIVE if it has spam score for a message and doesn't have ham score for it" do
      a = Tester.new('nosuchword nowordsuch heuristicspass')
      a.log_probability(:spam).should == 0.0
      a.log_probability(:ham).should == 0.0
      a.bayesian_factor.between?(REJECT_ALTERNATIVE_MAX, ACCEPT_ALTERNATIVE_MIN).should be_true
      a.classify_as!(:spam)
      a.bayesian_factor.should >= ACCEPT_ALTERNATIVE_MIN
    end

    it "should say NULL if it has ham score for a message and doesn't have spam score for it" do
      a = Tester.new('suchwordno nowordsuch heuristicspasss')
      a.log_probability(:spam).should == 0.0
      a.log_probability(:ham).should == 0.0
      a.bayesian_factor.between?(REJECT_ALTERNATIVE_MAX, ACCEPT_ALTERNATIVE_MIN).should be_true
      a.classify_as!(:ham)
      a.bayesian_factor.should < REJECT_ALTERNATIVE_MAX
    end
  end

  describe "#classify_as!" do
    it "should increase the index counts of the classified words" do
      lambda {
        Tester.new('zero').classify_as!(:ham)
      }.should change { Words['zero'][:ham] }.by(1)
    end
    it "should increment the learning examples count for all features" do
      FEATURES.each do |feature|
        lambda {
          Tester.new('zero').classify_as!(:ham)
        }.should change { Examples[feature][:ham] }.by(1)
      end
    end
    it "should not add new records for known keys" do
      a = Tester.new 'stuff unknown sofar'
      lambda {
        a.classify_as! :spam
      }.should change { GreenMidgetRecords.count }.by(6)
      lambda {
        a.classify_as! :ham
      }.should_not change { GreenMidgetRecords.count }
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
      Tester.new('www.myguy.com http://wearegeil.org').words.should == []
    end
  end

  describe "#pass_ham_heuristics?" do
    # it "shouldn't deal with comments having no url/email and less than LOWER_WORDS_LIMIT_FOR_COMMENTS words" do
    #   Tester.new('that seems quite alright', User.new, Comment).pass_ham_heuristics?.should_not be_true
    # end
    # it "should deal with comments having url/email independently of their word-count" do
    #   Tester.new('bye comment bad@wrong.com', User.new, Comment).pass_ham_heuristics?.should be_true
    # end
    # it "should deal with comments having more than LOWER_WORDS_LIMIT_FOR_COMMENTS words" do
    #   Tester.new_with_random_text(LOWER_WORDS_LIMIT_FOR_COMMENTS+1).pass_ham_heuristics?.should be_true
    # end
    # it "shouldn't deal with Posts having no url/email and less than LOWER_WORDS_LIMIT_FOR_POSTS words" do
    #   Tester.new('That is an example of a post that should not be dealt with by us', User.new, Post).pass_ham_heuristics?.should_not be_true
    # end
    # it "should deal with Posts having a url/email independently of their word-count" do
    #   Tester.new('bye post bad@wrong.com', User.new, Post).pass_ham_heuristics?.should be_true
    # end
    # it "should throw ArgumentError if given unexpected @spammable_class argument" do
    #   lambda{
    #     Tester.new('anything', User.new, 'Posttt').pass_ham_heuristics?
    #   }.should raise_error(ArgumentError)
    # end
    #
    # it "should say DUNNO for items, which have words but none of these words has been seen by the filter" do
    #   Tester.new_with_random_text(LOWER_WORDS_LIMIT_FOR_COMMENTS+1, 10).classify.should == 0
    # end
  end

  describe "#known_words" do
    it "should return an array of words for which the classifier had been given examples in the category" do
      a = Tester.new('this new word')
      a.known_words(:spam).should == ['this']
      a.classify_as!(:spam)
      a.known_words(:spam).should == a.words
    end
    it "known_words + new_words = words" do
      a = Tester.new('this new word')
      (a.known_words(:spam) + a.new_words(:spam)).should == a.words
    end
  end

  describe "extreme cases" do
    it "should fallback to training_examples_with_feature::any if there're no examples in the database for a particular feature" do
      # a new feature should be added with no examples and make sure the classifier won't break
      pending('todo')
    end
    it "throw an exception if no training examples were given, but it's asked for classification" do
      # if GreenMidgetRecords.count(:spam) or GreenMidgetRecords.count(:ham) is 0.0 => throw an exception
      pending('todo')
    end
  end

  describe "#feature_present?" do
    it "should throw NoMethodError if a feature look-up method has not been implemented" do
      pending('')
    end
  end
end
