# frozen_string_literal: true

module Utilities
  module GoogleScholarURL
    private

      def scholar_id_from_url(url)
        return if url.blank?

        URI.decode_www_form(URI.parse(url.to_s).query.to_s).find { |key, _| key == 'user' }&.last
      rescue URI::InvalidURIError
        nil
      end

      def normalized_doi(value)
        value.to_s.downcase.match(%r{10\.\S+/\S+})&.[](0)&.delete_suffix('.')
      end
  end
end
