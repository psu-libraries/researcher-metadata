# frozen_string_literal: true

class ScholarsphereImporter
  def call
    pbar = ProgressBarTTY.create(title: 'Importing ScholarSphere publication URLs', total: ss_dois.count)
    ss_dois.each do |k, v|
      doi_url = k.gsub('doi:', 'https://doi.org/')
      matching_pubs = Publication.where(doi: doi_url)
      matching_pubs.each do |p|
        v.each do |ss_oa_id|
          ss_oa_url = "#{ResearcherMetadata::Application.scholarsphere_base_uri}/resources/#{ss_oa_id}"
          p.open_access_locations.find_or_create_by(source: Source::SCHOLARSPHERE, url: ss_oa_url)
        end
      rescue StandardError => e
        log_error(e, {
                    k: k,
                    v: v,
                    publication_id: p&.id
                  })
      end
      pbar.increment
    rescue StandardError => e
      log_error(e, {
                  k: k,
                  v: v,
                  matching_pub_ids: (binding.local_variable_get(:matching_pubs)&.map(&:id) rescue nil)
                })
    end
    pbar.finish
  rescue StandardError => e
    log_error(e, {})
  end

  private

    def ss_dois
      @ss_dois ||= JSON.parse(response.body)
    end

    def response
      @response ||= HTTParty.get(
        "#{Settings.scholarsphere.endpoint}dois",
        headers: { 'X-API-KEY' => Settings.scholarsphere.client_key }
      )
    end

    def log_error(err, metadata)
      ImporterErrorLog.log_error(
        importer_class: self.class,
        error: err,
        metadata: metadata
      )
    end
end
