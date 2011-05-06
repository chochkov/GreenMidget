# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module SpamClassifier
  module Constants
    TOLERATED_URLS = /(soundcloud.com)|(facebook.com)|(myspace.com)|(twitter.com)/

    EMAIL_REGEX = /[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]/
    URL_REGEX   = /(?i)\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?]))/

    EXTERNAL_LINK_REGEX = Regexp.new(/(#{ EMAIL_REGEX })|(#{ URL_REGEX })/)

    # these are left out when scanning for words
    IGNORED_WORDS = %w(www com net biz org me)

    MIN_CHARACTERS_IN_WORD = 3
    MAX_CHARACTERS_IN_WORD = 20

    WORDS_SPLIT_REGEX = Regexp.new(/\w{#{ MIN_CHARACTERS_IN_WORD },#{ MAX_CHARACTERS_IN_WORD }}/)

    # all features used in the Baysian Filter in paralel with the words-occurrence probabilities
    FEATURES = %w(url_in_text email_in_text)

    # Decision making: Pr(spam | user,text) <=> SPAM_TRESHOLD * Pr(ham | user,text)
    SPAM_THRESHOLD = 3

    IS_SPAM = 1
    DUNNO   = 0
    IS_HAM  = -1
  end
end
