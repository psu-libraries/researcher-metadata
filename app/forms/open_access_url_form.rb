# frozen_string_literal: true

class OpenAccessURLForm
  include ActiveModel::Model

  attr_accessor :open_access_url

  validate :open_access_url_valid

  private

    def open_access_url_valid
      uri = URI.parse(open_access_url)
      if (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && !uri.host.nil?
        validate_response
      else
        add_format_error
      end
    rescue URI::InvalidURIError
      add_format_error
    end

    def valid_response_codes
      [200, 301, 302]
    end

    def validate_response
      response_code = HTTParty.head(open_access_url, follow_redirects: false).code
      unless valid_response_codes.include?(response_code)
        add_response_error
      end
    rescue SocketError
      add_response_error
    end

    def add_response_error
      errors.add(:open_access_url, I18n.t('models.open_access_url_form.validation_errors.url_response'))
    end

    def add_format_error
      errors.add(:open_access_url, I18n.t('models.open_access_url_form.validation_errors.url_format'))
    end
end
