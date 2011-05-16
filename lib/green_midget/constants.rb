# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  module Constants
    TOLERATED_URLS = /(soundcloud.com)|(facebook.com)|(myspace.com)|(twitter.com)/

    EMAIL_REGEX = /[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]/
    URL_REGEX   = /(?i)\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?]))/

    EXTERNAL_LINK_REGEX = Regexp.new(/(#{ EMAIL_REGEX })|(#{ URL_REGEX })/)

    STOP_WORDS = %w()

    MIN_CHARACTERS_IN_WORD = 3
    MAX_CHARACTERS_IN_WORD = 20

    WORDS_SPLIT_REGEX = Regexp.new(/\w{#{ MIN_CHARACTERS_IN_WORD },#{ MAX_CHARACTERS_IN_WORD }}/)

    FEATURES = %w(url_in_text email_in_text)

    # Decision making: Pr(alternative | text) <=> REJECT_THRESHOLD + Pr(null | text)
    REJECT_THRESHOLD      = Math::log(3.0)
    ACCEPTANCE_THRESHOLD  = 0.0

    ALTERNATIVE = 1
    DUNNO       = 0
    NULL        = -1

    CATEGORIES = [ :ham, :spam ]
  end
end
