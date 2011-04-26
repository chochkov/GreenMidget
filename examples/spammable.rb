# This class is an example of how an object could be written
# NOTES.
# 1. any of those methods might be omitted, then
# 2. more methods could be added to this class, best as private
#
class Spammable

  attr_accessor :text, :user, :spammable_class

  LOWER_WORDS_LIMIT_FOR_MESSAGES = 39

  LOWER_WORDS_LIMIT_FOR_POSTS    = 60

  LOWER_WORDS_LIMIT_FOR_COMMENTS = 20

  WORD_LIMITS = {
    Comment => LOWER_WORDS_LIMIT_FOR_COMMENTS,
    Post    => LOWER_WORDS_LIMIT_FOR_POSTS,
    Message => LOWER_WORDS_LIMIT_FOR_MESSAGES,
  }

  # implement your own heuristics check. If that method is defined and returns true the object would be used
  # for spam training
  def pass_ham_heuristics?
    yield (limit = WORD_LIMITS[spammable_class])
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

  # CONSIDER HOW TO EXTEND THE FEATURES?
  def features

  end

  private

  def set_object_class
    self.spammable_class = "Comment" || "Post" || "Message"
  end

end
