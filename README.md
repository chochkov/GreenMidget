On Bayesian Classification
----------

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

then add

    require 'green_midget'

to your Rakefile and run

    rake green_midget:setup

You're now done.

How it works
----------

GreenMidget

GreenMidget is a learner, so you will only expect effective classification from it only once it has received sufficient training. Training it means providing examples of messages for the categor  



Use it
----------

`GreenMidget` exposes two public methods as a start: `GreenMidget#classify_as!` and `GreenMidget#classify`. Let's do a three lines classification session and illustrate them

We'll start training `GreenMidget` with a spammy example

    GreenMidget.new(known_spam_text).classify_as! :spam

Similarly for legitimate examples

    GreenMidget.new(known_legit_text).classify_as! :ham

To get a classification decision we would

    decision = GreenMidget.new(new_text).classify

`decision` is now one of `[-1, 0, 1]` meaning respectively 'No spam', 'Not enough evidence', 'Spam'.

Extend it
----------

If the above functionality is not enough for you and you want to add custom logic to GreenMidget you can do that by extending the `GreenMidget::Base` class (check `extensions/sample.b` in the [code][green_midget_github] for an example):

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

If that's not enough too, you're welcome to [browse the code][green_midget_github] and either extend more parts of it or simply make your own fork of the project.

Benchmarking
----------

1. GreenMidget is optimised for classification operations (`classify` method), on which it's very efficient. The results below were obtained from classification on randomly generated messages of length _1 000 words_ (that's _very_ long for SoundCloud). Since GreenMidget runs on a relational database (through ActiveRecord) by default the table size impacts data fetch and write:

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

Trained on s

Benchmarks = > data

Efficiency = > for the sake of this article I ran a small off-production test to show some results on real data - I used 150 000 text items from records which we marked as good and records which we marked as not-the-best!

We'll be next building our own SoundCloud extensions to GreenMidget and use it, so expect to hear more from the student! Meanwhile, I'll be happy to answer everything concerning the project so do feel free to get in touch.

[green_midget_github]: http://github.com/chochkov/green_midget "Github repository"
[guidelines]: http://soundcloud.com/community-guidelines "Community guidelines"
