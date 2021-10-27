# frozen_string_literal: true

class UnpaywallPublicationImporter
  def import_all
    pbar = ProgressBar.create(title: 'Importing publication data from Unpaywall',
                              total: all_pubs.count)

    all_pubs.find_each do |p|
      query_unpaywall_for(p)
      pbar.increment
    end
    pbar.finish
  end

  def import_new
    pbar = ProgressBar.create(title: 'Importing publication data from Unpaywall',
                              total: new_pubs.count)

    new_pubs.find_each do |p|
      query_unpaywall_for(p)
      pbar.increment
    end
    pbar.finish
  end

  private

    def all_pubs
      Publication.where.not(doi: nil).where.not(doi: '')
    end

    def new_pubs
      all_pubs.where(unpaywall_last_checked_at: nil)
    end

    def create_new_locations(publication, new_locations, existing_locations)
      new_locations&.each do |new_location|
        match = existing_locations&.find { |e| new_location['url'] == e.url }

        if match.blank?
          publication.open_access_locations.create!(source: Source::UNPAYWALL,
                                                    url: new_location['url'],
                                                    landing_page_url: new_location['url_for_landing_page'],
                                                    pdf_url: new_location['url_for_pdf'],
                                                    host_type: new_location['host_type'],
                                                    is_best: new_location['is_best'],
                                                    license: new_location['license'],
                                                    oa_date: new_location['oa_date'],
                                                    source_updated_at: new_location['updated'],
                                                    version: new_location['version'])
        end
      end
    end

    def update_existing_locations(new_locations, existing_locations)
      existing_locations.each do |existing_location|
        match = new_locations&.find { |n| existing_location.url == n['url'] }

        if match.present?
          existing_location.update!(url: match['url'],
                                    landing_page_url: match['url_for_landing_page'],
                                    pdf_url: match['url_for_pdf'],
                                    host_type: match['host_type'],
                                    is_best: match['is_best'],
                                    license: match['license'],
                                    oa_date: match['oa_date'],
                                    source_updated_at: match['updated'],
                                    version: match['version'])
        else
          existing_location.try(:destroy)
        end
      end
    end

    def query_unpaywall_for(publication)
      unpaywall_json = nil
      find_url = URI::DEFAULT_PARSER.escape("https://api.unpaywall.org/v2/#{publication.doi_url_path}?email=openaccess@psu.edu")
      unpaywall_json = JSON.parse(HttpService.get(find_url))

      new_locations = unpaywall_json['oa_locations']
      existing_locations = publication.open_access_locations.where(source: Source::UNPAYWALL)

      create_new_locations(publication, new_locations, existing_locations)
      update_existing_locations(new_locations, existing_locations)

      publication.open_access_status = unpaywall_json['oa_status']
      publication.unpaywall_last_checked_at = Time.zone.now

      publication.save!

      # Unpaywall asks that users limit requests to no more than 100,000 per day.
      # Limiting to 1 request per second caps us at 86,400 requests per day.
      sleep 1 unless Rails.env.test?
    rescue StandardError => e
      ImporterErrorLog.log_error(
        importer_class: self.class,
        error: e,
        metadata: {
          publication_id: publication&.id,
          publication_doi_url_path: publication&.doi_url_path,
          unpaywall_json: unpaywall_json.to_s
        }
      )
    end
end
