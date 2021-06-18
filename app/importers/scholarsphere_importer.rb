class ScholarsphereImporter
  def call
    pbar = ProgressBar.create(title: 'Importing ScholarSphere publication URLs', total: ss_dois.count) unless Rails.env.test?
    ss_dois.each do |k, v|
      doi_url = k.gsub('doi:', 'https://doi.org/')
      matching_pubs = Publication.where(doi: doi_url)
      matching_pubs.each do |p|
        unless p.scholarsphere_open_access_url.present?
          ActiveRecord::Base.transaction do
            # Update the open access status of the publication by adding the first ScholarSphere
            # URL that's listed for this publication's DOI.
            p.scholarsphere_open_access_url = "#{ResearcherMetadata::Application.scholarsphere_base_uri}/resources/#{v.first}"
            p.save!
            # Clear any legacy upload timestamps on related authorships. Our old ScholarSphere
            # workflow assumes that this timestamp is a temporary indicator for RMD admins and
            # that it should be cleared as soon as a ScholarSphere URL is added to the publication.
            # That now applies regardless of how the URL was obtained. So since we're setting the
            # URL here, we need to also clear the timestamp. The new ScholarSphere workflow obviates
            # this timestamp, so once the remnants of the old workflow are cleaned up, the timestamp
            # field will be removed altogether.
            p.authorships.update_all(scholarsphere_uploaded_at: nil)
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
      headers: {'X-API-KEY' => Rails.application.config.x.scholarsphere['SS_CLIENT_KEY']}
    )
  end
end
