[![Build
Status](https://secure.travis-ci.org/chochkov/GreenMidget.png)](http://travis-ci.org/chochkov/GreenMidget)

On Bayesian Classification
----------

This project started during an internship at SoundCloud.

Using SoundCloud's private messaging means that you can effectively reach out
to everyone on the Cloud. On top of that, you have track commenting, groups
posting, forum topics, track sharing - we care about your voice being heard!
And read.

I'll put this in some perspective and say that we're now having daily text
exchange volume in the order of hundreds of thousands. And it's also rapidly
going up.

And while most of this runs smoother than Berliner beer on a SoundCloud Friday,
violations to our [Community guidelines][guidelines] are starting to be less
and less of an exception. So I've been given the task to address this and
build a system that progressively learns how to tell good community behaviour
from less good - welcome to the:

GreenMidget
----------

GreenMidget is a trainable, feature-full Bayesian text classifier. Out of the
box it's super straightforward to use, but it also offers easy customisation
options. It's a Ruby gem and today we're open sourcing it, so you can start
with it within a minute after the:

Installation
----------

If you're using bundle, simply add the following to your Gemfile

    gem 'green_midget'

and then run

    bundle install

after which (so that you get the ActiveRecord backend ready):

    bundle exec rake green_midget:setup:active_record

This creates a `green_midget_records` table and populate some entried there

You're now done.

Try it out (right on the CLI)
----------
After you install the gem a shell executable is available for a quick play
with an online GreenMidget server trained on ~ 9000 public spam and ham
examples posted on SoundCloud as posts or track comments.

    $ greenmidget 'buy cheap bags online'
    $ greenmidget 'upload and share cool tracks online'
    $ greenmidget potential_spam.txt # will read the file and classify the text

Go ahead and try around a bit, but keep in mind that this online service is in a
very early training stage and lacks even basic features (see below).

How it works
----------

GreenMidget is a Naive Bayes implementation that uses a Log ratio of spam vs
ham probabilities for a given object to classify it to any of the categories.
There's an indecisive range as well - by default between 0 and Log(3).
Everything under 0 will be considered legit and above Log(3) will be spam.

GreenMidget adjusts the probabilities for individual words from training with
known examples and thus it improves its capability.

You can define further features (perhaps based on characteristics of the objects
you have to deal with) and use them to calculate probabilities. You can also
define heuristic checks for either category (see below for more on how to do
these).

Use it
----------

`GreenMidget::Classifier` is the interaction class that is there after
installation. It exposes two public instance methods as a start:
`GreenMidget::Classifier#classify_as!` and `GreenMidget::Classifier#classify`.
We'll do a three lines classification session and illustrate them.

We'll start training `GreenMidget` with a spammy example:

    GreenMidget::Classifier.new(known_spam_text).classify_as! :spam

Similarly for legitimate examples

    GreenMidget::Classifier.new(known_legit_text).classify_as! :ham

After we've given to it some training data, we can start classifying unknown
text:

    decision = GreenMidget::Classifier.new(new_text).classify

`decision` is now in `[ -1, 0, 1 ]` meaning respectively 'No spam',
'Not enough evidence', 'Spam'.

Extend it
----------

If the above functionality is not enough for you and you want to add custom
logic to GreenMidget you can do that by extending the `GreenMidget::Base`
class (check `lib/green_midget/extensions/sample.b` in the [code][green_midget_github]
for an example):

* Implement heuristics logic, which will directly classify incoming object as a
given category. Example:

    def pass_ham_heuristics?
      words.count > 5 || url_in_text?
    end

  This method will be `true` for longer text or such that contains an external
  url. In this case the classifier would go on to the actual testing procedure.
  If `false`, however, the procedure will not be done and the classifier will
  return the ham category as a result. Note the default
  `GreenMidget::Base#words` and `GreenMidget::Base#url_in_text?`

  All heuristic checks return `true` by default so it's up to you whether you
  will define and use heuristics at all or not. However, using them can help
  you integrate your application context and decrease classification error
  chance especially at the edge cases.

* Expand the source of evidence. Traditionally, _naive_ Bayesian text
classifiers see individual words as evidence and calculate category-likelihoods
for each word. But there could be more than that in your application context,
eg. user's data or specific text features.

  By default GreenMidget comes with two feature definitions `url_in_text` and
  `email_in_text`, but you can implement as many more as you want by writing a
  boolean method that checks for the feature:

  ```ruby
    def regular_user?
      @user.sign_up_count > 10
    end
   ```

  and then implement a `features` method that returns an array with your custom
  feature names:

    def features
      ['regular_user', .... ]
    end

  (do make sure that the array entry is the same as the name of the method that
  would be checking for this feature)

  The GreenMidget features definitions have more weight on shorter texts and
  less weight on longer thus they provide a ground source of evidence for
  GreenMidget's classification.

If that's not enough too, see the Contribute section below.

Performance
----------

GreenMidget uses ActiveRecord as backend and this guarantees wide support and
easy setup, however it's less performant than other data stores especially on
training operations. You should do such tasks asynchronously on real
applications. A future version backed on Redis is planned.

Classification Efficiency
----------

Obviously this will depend on the training data that you have, but do give a
try to the Heroku GreenMidget app from the supplied CLI tool for a start (see
above for examples) or type:

    $ greenmidget

on your shell for a help message. The online classifier for example lacks many
possible features such as heuristic checks, words stamming, stop words, etc.
It's only trained on the word occurrences of a total of 9000 messages (4500 of
each spam and ham).

During the development tests at SoundCloud, with those features in place, we
achieved more than 98% correct classification of spam objects using GreenMidget.

Thanks
----------

massively to everyone at SoundCloud for the help during the development of
GreenMidget.

Contribute
----------

Just do the standard:

  * Make a fork and then:
    * run `bundle` to setup dependencies
    * and `bundle exec rake` to run the specs
  * Make a patch
  * Send a Pull Request

[green_midget_github]: http://github.com/chochkov/GreenMidget "Github repository"
[guidelines]: http://soundcloud.com/community-guidelines "Community guidelines"
