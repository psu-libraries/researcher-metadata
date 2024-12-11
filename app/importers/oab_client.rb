# frozen_string_literal: true

class OABClient
  def self.query_open_access_button(publication)
    find_url = if publication.doi.present?
                 "https://api.openaccessbutton.org/find?id=#{CGI.escape(publication.doi_url_path)}"
               else
                 "https://api.openaccessbutton.org/find?title=#{CGI.escape(cleaned_title(publication))}"
               end

    json = publication.publication_type == 'Extension Publication' ? {} : JSON.parse(HttpService.get(find_url))
    OABResponse.new(json)
  end

  # Open Access Button will block requests that they detect as "bot behavior"
  # We strip some characters here to not get flagged as a bot and blocked
  def self.cleaned_title(publication)
    publication.title.tr("'\"", '')
  end
end
