[![Build
Status](https://secure.travis-ci.org/chochkov/GreenMidget.png)](http://travis-ci.org/chochkov/GreenMidget)

On Bayesian Classification
----------

This project started during an internship at SoundCloud.

Using SoundCloud's private messaging means that you can effectively reach out to everyone on the Cloud. On top of that, you have track commenting, groups posting, forum topics, track sharing - we care about your voice being heard! And read.

I'll put this in some perspective and say that we're now having daily text exchange volume in the order of hundreds of thousands. And it's also rapidly going up.

And while most of this runs smoother than Berliner beer on a SoundCloud Friday, violations to our [Community guidelines][guidelines] are starting to be less and less of an exception. So I've been given the task to address this and build a system that progressively learns how to tell good community behaviour from less good - welcome to the:

GreenMidget
----------

GreenMidget is a trainable, feature-full Bayesian text classifier. Out of the box it's super straightforward to use, but it also offers easy customisation options. It's a Ruby gem and today we're open sourcing it, so you can start with it within a minute after the:

Installation
----------

You are very likely (but not necessarily) gonna be on a Rails app, so just add

    gem 'green_midget'

to your Gemfile and run

    bundle install

after which (so that you get the ActiveRecord backend ready):

    rake green_midget:setup:active_record # creates a green_midget_records table and populate some entried there

You're now done.

How it works
----------

GreenMidget learns to classify between two categories, so what you should first do is provide training examples for each of those two categories. See below.

Use it
----------

`GreenMidget::Classifier` is the interaction class that is there after installation. It exposes two public instance methods as a start: `GreenMidget::Classifier#classify_as!` and `GreenMidget::Classifier#classify`. We'll do a three lines classification session and illustrate them.

We'll start training `GreenMidget` with a spammy example:

    GreenMidget::Classifier.new(known_spam_text).classify_as! :spam

Similarly for legitimate examples

    GreenMidget::Classifier.new(known_legit_text).classify_as! :ham

After we've given to it some training data, we can start classifying unknown text:

    decision = GreenMidget::Classifier.new(new_text).classify

`decision` is now in `[ -1, 0, 1 ]` meaning respectively 'No spam', 'Not enough evidence', 'Spam'.

Extend it
----------

If the above functionality is not enough for you and you want to add custom logic to GreenMidget you can do that by extending the `GreenMidget::Base` class (check `lib/green_midget/extensions/sample.b` in the [code][green_midget_github] for an example):

* Implement heuristics logic, which will directly classify incoming object as a given category. Example:

    def pass_ham_heuristics?
      words.count > 5 || url_in_text?
    end

  This method will be `true` for longer text or such that contains an external url. In this case the classifier would go on to the actual testing procedure. If `false`, however, the procedure will not be done and the classifier will return the ham category as a result. Note the native `GreenMidget::Base#words` and `GreenMidget::Base#url_in_text?`

  All heuristic checks return `true` by default so it's up to you whether you will define and use heuristics at all or not. However, using them can help you integrate your application context and decrease classification error chance especially at the edge cases.

* Expand the source of evidence. Traditionally, _naive_ Bayesian text classifiers see individual words as evidence and calculate category-likelihoods for each word. But there could be more than that in your application context, eg. user's data or specific text features.

  By default GreenMidget comes with two feature definitions `url_in_text` and `email_in_text`, but you can implement as many more as you want by writing a boolean method that checks for the feature:

    def regular_user?
      @user.sign_up_count > 10
    end

  and then implement a `features` method that returns an array with your custom feature names:

    def features
      ['regular_user', .... ]
    end

  (do make sure that the array entry is the same as the name of the method that would be checking for this feature)

  The GreenMidget features definitions have more weight on shorter texts and less weight on longer thus they provide a ground source of evidence for GreenMidget's classification.

If that's not enough too, see the Contribute section below.

Benchmarking
----------

Before moving on, let's say that `GreenMidget` is intended for asynchronous spam checks. Using ActiveRecord as backend has the benefit of wide support and easy setup, but as it also means that the time performance will become progressively worse the more training you provide.

1. GreenMidget is optimised for classification operations (`classify` method), on which it's relatively efficient. The results below were obtained from classification on randomly generated messages of length _1 000 words_ (that's _very_ long for SoundCloud). Since GreenMidget runs on a relational database (through ActiveRecord) by default the table size impacts data fetch and write:

	* on ~ 10 000 table rows = 0.0703 seconds / message
	* on ~ 100 000 rows = 0.2082 sec / message
	* on ~ 500 000 rows = 0.6505 sec / message
	* on ~ 1 000 000 rows = 0.6773 sec / messages

2. Training operations (`classify_as!`) are, however, less performant because they invoke a database write per word. Under the same conditions as above, the training times of randomly generated messages follows:

	* on ~ 10 000 table rows = 1.5984 seconds / message
	* on ~ 100 000 rows = 0.1303 sec / message
	* on ~ 500 000 rows = 1.7185 sec / message
	* on ~ 1 000 000 rows = 2.5335 sec / message

Classification Efficiency
----------

TODO: give test results; provide a web interface to a trained classifier using some of SoundCloud's spam and legit data; give production experience from DigitaleSeiten.

Contribute
----------

Let me know on any feedback or feature requests. If you want to hack on the
code, just do that!

  * Make a fork
    * `git clone git@github.com:chochkov/GreenMidget.git`
    * `bundle`
    * `bundle exec rake` to run the specs
  * Make a patch
  * Send a Pull Request

[green_midget_github]: http://github.com/chochkov/GreenMidget "Github repository"
[guidelines]: http://soundcloud.com/community-guidelines "Community guidelines"
