# frozen_string_literal: true

class HttpService
  def self.get(url, attempts = 1)
    HTTParty.get(url).to_s
  rescue Net::ReadTimeout, Net::OpenTimeout
    attempts += 1
    if attempts <= 10
      get(url, attempts)
    else
      raise
    end
  end
end
