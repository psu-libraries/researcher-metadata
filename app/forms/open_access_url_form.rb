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

  def validate_response
    unless HTTParty.get(open_access_url).code == 200
      errors.add(:open_access_url, I18n.t('models.open_access_url_form.validation_errors.url_response'))
    end
  end

  def add_format_error
    errors.add(:open_access_url, I18n.t('models.open_access_url_form.validation_errors.url_format'))
  end
end
