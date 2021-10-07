class ScholarsphereImporter
  def call
    pbar = ProgressBar.create(title: 'Importing ScholarSphere publication URLs', total: ss_dois.count) unless Rails.env.test?
    ss_dois.each do |k, v|
      doi_url = k.gsub('doi:', 'https://doi.org/')
      matching_pubs = Publication.where(doi: doi_url)
      matching_pubs.each do |p|
        if p.scholarsphere_open_access_url.blank?
          ActiveRecord::Base.transaction do
            # Update the open access status of the publication by adding the first ScholarSphere
            # URL that's listed for this publication's DOI.
            p.scholarsphere_open_access_url = "#{ResearcherMetadata::Application.scholarsphere_base_uri}/resources/#{v.first}"
            p.save!
          end
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
