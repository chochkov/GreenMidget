# This class is an example of how an object could be written
# NOTES.
# 1. any of those methods might be omitted
# 2. more methods could be added to this class, best as private
#
class Spammable

  include SpamClassifier

  attr_accessor :text, :user, :spammable_class

  LOWER_WORDS_LIMIT_FOR_MESSAGES = 39

  LOWER_WORDS_LIMIT_FOR_POSTS    = 60

  LOWER_WORDS_LIMIT_FOR_COMMENTS = 20

  WORD_LIMITS = {
    Comment => LOWER_WORDS_LIMIT_FOR_COMMENTS,
    Post    => LOWER_WORDS_LIMIT_FOR_POSTS,
    Message => LOWER_WORDS_LIMIT_FOR_MESSAGES,
  }

  def initialize(text, user, spammable_class)
    self.text = text
    self.user = user
    self.spammable_class = spammable_class
    @spammable = self
  end

  # implement your own heuristics check. If that method is defined and returns true the object would be used
  # for spam training
  def pass_ham_heuristics?

    if (limit = WORD_LIMITS[spammable_class])

      # what happens with these methods
      url_in_text? || email_in_text? || words.count > limit
    else
      raise ArgumentError.new("Cannot classify type #{spammable_class.inspect}")
    end

  end

  # implement your own heuristics check. If that method is defined and returns true the object would be used
  # for ham training
  def pass_spam_heuristics?
    # TODO implement two things:
    # 1. time after signup / number of object of the same type sent by the user
    # 2. see the last 5 messages of the same type and calculate the
    # distance between them (bzw between fractions of them).

    # ((Time.now - @user.created_at) > THREAS) / @user.messages.count
  end

  def features
    %w(custom_username custom_avatar tracks_uploaded)
  end

  def custom_username?
    !(user.username =~ /user\d+/)
  end

  def custom_avatar?
    user.avatars.size > 0
  end

  def tracks_uploaded?
    user.tracks.size > 0
  end

end
