# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
class Sample < SpamClassifier::Base
  attr_accessor :user

  def initialize(text, user)
    @text = text
    @user = user
  end

  private

  def features
    %w(regular_user)
  end

  def regular_user?

  end
end
