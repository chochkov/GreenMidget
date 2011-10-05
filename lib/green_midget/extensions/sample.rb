# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
#
# This is a sample of how to define new features to be
# tracked by GreenMidget. Eg: define user features and check
# them on the message sender.
#

class Sample < GreenMidget::Base
  attr_accessor :user

  def initialize(text, user)
    @text = text
    @user = user
  end

  private

  def features
    %w(regular_user) + super
  end

  def regular_user?
    # implement a method checking user type
  end
end
