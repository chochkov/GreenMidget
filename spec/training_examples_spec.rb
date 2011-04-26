require 'spec_helper'

describe TrainingExamples do

  before(:each) do
    SpamClassificationIndex.delete_all
    @examples_general = TrainingExamples.create!('training_examples_with_feature::words')
    @examples_general.update_attributes({:spam_count => 1000, :ham_count => 1000})
    SpamClassifier::FEATURES.concat(%w(notfound new existing))
    Features['existing']
    SpamClassificationIndex.write!
    SpamClassificationIndex.class_eval{ @@cache = nil }
  end

  describe "#[]()" do
    it "should raise an error if given an non-existing feature" do
      lambda do
        TrainingExamples['wrong']
      end.should raise_error(ArgumentError)
    end
    it "should return training_examples_with_feature::words if given a new feature that has no examples in both categories yet (i.e. new feature!)" do
      TrainingExamples.find_by_key('training_examples_with_feature::new').should == nil
      TrainingExamples['new'][:spam].should == @examples_general[:spam]
      TrainingExamples['new'][:ham].should  == @examples_general[:ham]

      # Let's make sure now that it will return the appropriate feature when records exist.
      TrainingExamples.create!('training_examples_with_feature::new')
      TrainingExamples.find_by_key('training_examples_with_feature::new').update_attributes({ :spam_count => 1, :ham_count => 3 })
      TrainingExamples.class_variable_set("@@cache", {})
      TrainingExamples['new'][:spam].should == 1
      TrainingExamples['new'][:ham].should  == 3
    end
    it "throw exception if training_examples_with_feature::words has zero count for any category " do
      call_words = lambda do
        TrainingExamples['words']
      end
      SpamClassificationIndex.delete_all

      # 1. Record doesnt exists yet:
      call_words.should raise_error(ZeroDivisionError)

       # 2. now record exists but both "train...::word" => spam_count and ham_count are zeros:
      TrainingExamples.create!('training_examples_with_feature::words')
      call_words.should raise_error(ZeroDivisionError)

      # 3. now only one key is zero:
      TrainingExamples.find_by_key('training_examples_with_feature::words').update_attributes({ :spam_count => 0, :ham_count => 1 })
      call_words.should raise_error(ZeroDivisionError)

      # 4. now we have positive numbers - let's divide on them!
      TrainingExamples.find_by_key('training_examples_with_feature::words').update_attributes({ :spam_count => 1, :ham_count => 1 })
      TrainingExamples.class_variable_set("@@cache", {})
      call_words.should_not raise_error(ZeroDivisionError)
    end
  end

  describe "#probability_for" do
    it "should return Feature[feature] / TrainingExamples[feature]" do
      item = TrainingExamples.create!('training_examples_with_feature::url_in_text')
      item.update_attributes({:spam_count => 150, :ham_count => 1000})
      a = TrainingExamples.find_by_key('training_examples_with_feature::url_in_text')
      a[:spam].should_not == 0
      a[:ham].should_not == 0
      TrainingExamples['url_in_text'].probability_for(:spam).should == 150.0/(1000 + 150)
    end
  end

end
