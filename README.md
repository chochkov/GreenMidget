SpamClassifier
====

In a nutshell
-------------


Why do you want this?
---------------------

Kickstart
=========
### Basic installation

Install gem with

    gem install spam_classifier

or, if you use bundler for your project, add the line

    gem 'spam_classifier'

to your Gemfile and run

    bundle install

### Rakefile integration

Next you should setup up the datastore for the classifier. Go to your Rakefile and add

    require 'spam_classifier'

then call
    
    rake -T

to get a list of available tasks. Execute the installer by

    rake spam_classifier:setup

Usage
=====


Contributing to tuev
--------------------
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov. See LICENSE.txt for further details.
