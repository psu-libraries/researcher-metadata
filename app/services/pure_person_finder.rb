# frozen_string_literal: true

class PurePersonFinder < PureAPIClient
  def detect_publication_author(pub)
    pub.users.each do |u|
      return u if detect_person(u)
    end
    nil
  end

  private

    def detect_person(user)
      response = HTTParty.get(
        "#{base_url}/persons/#{user.pure_uuid}",
        headers: { 'api-key' => pure_api_key.to_s }
      )
      response.code == 200
    end
end
