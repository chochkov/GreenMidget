# This class is an example of how an object could be written
# NOTES.
# 1. any of those methods might be omitted
# 2. more methods could be added to this class, best as private
#
class Spammable < SpamClassifier::Base

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
  end

  private

  def pass_ham_heuristics?
    if (limit = WORD_LIMITS[spammable_class])
      url_in_text? || email_in_text? || words.count > limit
    else
      raise ArgumentError.new("Cannot classify type #{spammable_class.inspect}")
    end
  end

  def pass_spam_heuristics?
    # TODO implement two things:
    # 1. time after signup / number of object of the same type sent by the user
    # 2. see the last 5 messages of the same type and calculate the
    # distance between them (bzw between fractions of them).
  end

  def features
    super + %w(custom_username custom_avatar tracks_uploaded)
  end

  def url_in_text?
    UrlDetection.new(text).any?
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

  # --- Souncdloud custom Loggers ---

  def log_classification
    yaml_dump = YAML::dump({
      :general => {
        :user_id              => @user.id,
        :text                 => words.join(' '),
        :spammable_class      => @spammable_class.to_s,
        :words_count          => words.count,
        :features_count       => features.count,
        :all_features_count   => FEATURES.count,
        :tested_on            => Time.now,
      },
      :spam => {
        :category_probability => category_probability(:spam),
        :from_words           => words_probability_for(:spam),
        :from_features        => features_probability_for(:spam),
        :known_words          => known_words(:spam).count,
        :spam_examples        => TrainingExamples.with_words[:spam],
      },
      :ham => {
        :category_probability => category_probability(:ham),
        :from_words           => words_probability_for(:ham),
        :from_features        => features_probability_for(:ham),
        :known_words          => known_words(:ham).count,
        :spam_examples        => TrainingExamples.with_words[:ham],
      }
    })
    Rails.logger.debug "=== SPAM CLASSIFICATION ==="
    Rails.logger.debug yaml_dump
    Rails.logger.debug "=== END ==="
  end

  def log_training
    # TODO: implement SC custom logger for training event.
  end

end
