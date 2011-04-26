module SpamClassifier
  class UrlDetection
    def initialize(text)
      @text = text
    end

    def any?
      non_tolerated_urls.size > 0
    end

    private

    def html
      HtmlFormatter.format_html(@text)
    end

    def links
      Nokogiri::HTML(html).search('a[href]').map { |link| link.attr('href') }.compact
    end

    def urls
      links.map { |l| URI.parse(l) rescue nil }.compact
    end

    def non_tolerated_urls
      urls.reject do |url|
        url.host && url.host.to_s.downcase =~ Constants::TOLERATED_URLS
      end
    end
  end
end
