# frozen_string_literal: true

class ScholarsphereImporter
  def call
    pbar = ProgressBar.create(title: 'Importing ScholarSphere publication URLs', total: ss_dois.count) unless Rails.env.test?
    ss_dois.each do |k, v|
      doi_url = k.gsub('doi:', 'https://doi.org/')
      matching_pubs = Publication.where(doi: doi_url)
      matching_pubs.each do |p|
        v.each do |ss_oa_id|
          ss_oa_url = "#{ResearcherMetadata::Application.scholarsphere_base_uri}/resources/#{ss_oa_id}"
          p.open_access_locations.find_or_create_by(source: 'ScholarSphere', url: ss_oa_url)
        end
      end
      pbar.increment unless Rails.env.test?
    end
    pbar.finish unless Rails.env.test?
  end

  private

    def ss_dois
      @ss_dois ||= JSON.parse(response.body)
    end

    def response
      @response ||= HTTParty.get(
        "#{Rails.application.config.x.scholarsphere['SS4_ENDPOINT']}dois",
        headers: { 'X-API-KEY' => Rails.application.config.x.scholarsphere['SS_CLIENT_KEY'] }
      )
    end
end
