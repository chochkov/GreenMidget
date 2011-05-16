# Copyright (c) 2011, SoundCloud Ltd., Nikola Chochkov
module GreenMidget
  class UrlDetection
    def initialize(text)
      @text = text
    end

    def any?
      non_tolerated_urls.size > 0
    end

    private

    def urls
      @text.scan(GreenMidget::URL_REGEX).flatten.reject(&:nil?)
    end

    def non_tolerated_urls
      urls.reject do |url|
        url.to_s.downcase =~ GreenMidget::TOLERATED_URLS
      end
    end
  end
end
