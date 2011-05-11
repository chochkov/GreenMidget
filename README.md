On sensing the
----------

Using SoundCloud's private messaging means that you can effectively reach out to everyone on the Cloud. On top of that, you have track commenting, groups posting, forum topics, track sharing - we care about your voice being heard! And read.

I'll put things in some perspective and say that we're now having daily text exchange volume in the order of hundreds of thousands. And it's also rapidly going up.

And while most of this runs smoother than Berliner beer on a SoundCloud friday, violations to our [Community guidelines][guidelines] are starting to be less and less of an exception. So I've been given the task to address this and build a system that progressively learns how to tell good community behaviour from less good - enter:

Kindergartener
----------

Kindergartener is a trainable, feature-full Bayesian text classifier. Out of the box it's super straightforward to use, but it also offers easy customisation options. It's a Ruby gem and today we're open sourcing it, so you can start with it within a minute from its:

Installation
----------

You are very likely (but not necessarily) gonna be on a Rails app, so just add

    gem 'kindergartener'

to your Rakefile and run

    bundle install

then add

    require 'kindergartener'

to your Rakefile and run

    rake kindergartener:setup

You're now done.

How it works
----------

Kindergartener is a learner, so you will only expect effective classification from it after it has received sufficient training first. We're gonna be publishing data from our experience with Kindergartener, but surely its performance will vary depending on the text feed that it'll be exposed to.

Use it
----------

`Kindergartener` exposes two public methods from the start: `Kindergartener#classify_as!` and `Kindergartener#classify`. Let's do a three lines classification session and illustrate them

We'll start training `Kindergartener` with a spammy example

    Kindergartener.new(known_spam_text).classify_as! :spam

Similarly for a legitimate example

    Kindergartener.new(known_legit_text).classify_as! :ham

Now suppose we've provided enough training examples to Kindergartener, we may then use it on new text and get some output

    decision = Kindergartener.new(new_text).classify

`decision` is now one of `[-1, 0, 1]` meaning respectively 'No spam', 'Not enough evidence', 'Spam'.

Extend it
----------

If you want to add custom logic to Kindergartener you can do that by extending the `Kindergartener::Base` class (check `extensions/sample.rb` in the [code][kindergartener_github] for an example):

* Implement heuristics logic, which will directly classify incoming object as a given category. Example:

        def pass_ham_heuristics?
          words.count > 5 || url_in_text?
        end

  This method will be `true` for longer text or such that contains an external url. In this case the classifier would go on to the actual testing procedure. If `false`, however, the procedure will not be done and the classifier will return that ham category as a result. Note the native `Kindergartener::Base#words` and `Kindergartener::Base#url_in_text?`

  All heuristic checks return `true` by default so it's up to you whether you will define and use heuristics or not. However, using them can help you integrate your application context and decrease classification error chance especially at the edge cases.

* Expand the source of evidence. Traditionally, _naive_ Bayesian text classifiers see individual words as evidence and calculate category-likelihoods for each word. But there could be more than that in your application context (eg. users data).

  In order to do that, you will write a boolean method for each feature that you want to be tracking:

         def regular_user?
           @user.sign_up_count > 10
         end

  Then implement a `features` method that return an array with your new features like this:

         def features
           ['regular_user']
         end

  Do make sure that the value in this array is the same as the name of the method that would be checking for this feature.

Or, simply fork the project and tweak it as you please. I'd be most glad to hear about this then.

Final words and future work
----------

We'll experimenting with different extensions

see how far could we get by using resampling in order to boost performance

I'd be more than happy to hear *anything* you have to say about Kindergartener

todo: apply efficiency results and benchmarks

[kindergartener_github]: http://github.com/soundcloud/kindergartener "Github repository"
[guidelines]: http://soundcloud.com/community-guidelines "Community guidelines"
