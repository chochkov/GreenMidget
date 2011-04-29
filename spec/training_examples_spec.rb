require 'spec_helper'

describe SpamClassifier::TrainingExamples do

  before(:each) do
    SpamClassifier::SpamClassificationIndex.delete_all
    @examples_general = SpamClassifier::TrainingExamples.create!('training_examples_with_feature::words')
    @examples_general.update_attributes({:spam_count => 1000, :ham_count => 1000})
    SpamClassifier::FEATURES.concat(%w(notfound new existing))
    SpamClassifier::Features['existing']
    SpamClassifier::SpamClassificationIndex.write!
    SpamClassifier::SpamClassificationIndex.class_eval{ @@cache = nil }
  end

  describe "#[]()" do
    it "should raise an error if given an non-existing feature" do
      lambda do
        SpamClassifier::TrainingExamples['wrong']
      end.should raise_error(ArgumentError)
    end
    it "should return training_examples_with_feature::words if given a new feature that has no examples in both categories yet (i.e. new feature!)" do
      SpamClassifier::TrainingExamples.find_by_key('training_examples_with_feature::new').should == nil
      SpamClassifier::TrainingExamples['new'][:spam].should == @examples_general[:spam]
      SpamClassifier::TrainingExamples['new'][:ham].should  == @examples_general[:ham]

      # Let's make sure now that it will return the appropriate feature when records exist.
      SpamClassifier::TrainingExamples.create!('training_examples_with_feature::new')
      SpamClassifier::TrainingExamples.find_by_key('training_examples_with_feature::new').update_attributes({ :spam_count => 1, :ham_count => 3 })
      SpamClassifier::TrainingExamples.class_variable_set("@@cache", {})
      SpamClassifier::TrainingExamples['new'][:spam].should == 1
      SpamClassifier::TrainingExamples['new'][:ham].should  == 3
    end
    it "throw exception if training_examples_with_feature::words has zero count for any category " do
      call_words = lambda do
        SpamClassifier::TrainingExamples['words']
      end
      SpamClassifier::SpamClassificationIndex.delete_all

      # 1. Record doesnt exists yet:
      call_words.should raise_error(ZeroDivisionError)

       # 2. now record exists but both "train...::word" => spam_count and ham_count are zeros:
      SpamClassifier::TrainingExamples.create!('training_examples_with_feature::words')
      call_words.should raise_error(ZeroDivisionError)

      # 3. now only one key is zero:
      SpamClassifier::TrainingExamples.find_by_key('training_examples_with_feature::words').update_attributes({ :spam_count => 0, :ham_count => 1 })
      call_words.should raise_error(ZeroDivisionError)

      # 4. now we have positive numbers - let's divide on them!
      SpamClassifier::TrainingExamples.find_by_key('training_examples_with_feature::words').update_attributes({ :spam_count => 1, :ham_count => 1 })
      SpamClassifier::TrainingExamples.class_variable_set("@@cache", {})
      call_words.should_not raise_error(ZeroDivisionError)
    end
  end

  describe "#probability_for" do
    it "should return Feature[feature] / TrainingExamples[feature]" do
      item = SpamClassifier::TrainingExamples.create!('training_examples_with_feature::url_in_text')
      item.update_attributes({:spam_count => 150, :ham_count => 1000})
      a = SpamClassifier::TrainingExamples.find_by_key('training_examples_with_feature::url_in_text')
      a[:spam].should_not == 0
      a[:ham].should_not == 0
      SpamClassifier::TrainingExamples['url_in_text'].probability_for(:spam).should == 150.0/(1000 + 150)
    end
  end

end
