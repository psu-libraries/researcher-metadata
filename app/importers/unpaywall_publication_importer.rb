# frozen_string_literal: true

class UnpaywallPublicationImporter
  def import_all
    pbar = ProgressBarTTY.create(title: 'Importing publication data from Unpaywall',
                                 total: all_pubs.count)

    all_pubs.find_each do |p|
      import_from_unpaywall(p)
      pbar.increment
    end
    pbar.finish
  end

  def import_new
    pbar = ProgressBarTTY.create(title: 'Importing publication data from Unpaywall',
                                 total: new_pubs.count)

    new_pubs.find_each do |p|
      import_from_unpaywall(p)
      pbar.increment
    end
    pbar.finish
  end

  private

    def all_pubs
      Publication.where.not(doi: nil).where.not(doi: '').includes(:open_access_locations)
    end

    def new_pubs
      all_pubs.where(unpaywall_last_checked_at: nil)
    end

    def import_from_unpaywall(publication)
      unpaywall_json = query_unpaywall_for(publication)
      update_publication(publication, unpaywall_json)

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

    def update_publication(publication, unpaywall_json)
      unpaywall_locations = unpaywall_json['oa_locations'].presence || []
      existing_locations = publication.open_access_locations.filter { |l| l.source == Source::UNPAYWALL }

      existing_locations_by_url = existing_locations.index_by(&:url)
      unpaywall_locations_by_url = unpaywall_locations.index_by { |l| l['url'] }

      ActiveRecord::Base.transaction do
        unpaywall_locations.each do |unpaywall_location_data|
          unpaywall_url = unpaywall_location_data['url']
          open_access_location = existing_locations_by_url.fetch(unpaywall_url) { build_new_oal(publication, unpaywall_url) }

          update_open_access_location(open_access_location, unpaywall_location_data)
          open_access_location.save!
        rescue StandardError => e
          ImporterErrorLog.log_error(
            importer_class: self.class,
            error: e,
            metadata: {
              publication_id: publication&.id,
              publication_doi_url_path: publication&.doi_url_path,
              unpaywall_json: unpaywall_location_data
            }
          )
        end

        locations_to_delete = existing_locations.reject { |l| unpaywall_locations_by_url.key? l.url }
        locations_to_delete.each(&:destroy)

        publication.open_access_status = unpaywall_json['oa_status']
        publication.unpaywall_last_checked_at = Time.zone.now

        publication.save!
      end
    end

    def query_unpaywall_for(publication)
      find_url = URI::DEFAULT_PARSER.escape("https://api.unpaywall.org/v2/#{publication.doi_url_path}?email=openaccess@psu.edu")
      JSON.parse(HttpService.get(find_url))
    end

    def update_open_access_location(open_access_location, unpaywall_json)
      open_access_location.assign_attributes(
        landing_page_url: unpaywall_json['url_for_landing_page'],
        pdf_url: unpaywall_json['url_for_pdf'],
        host_type: unpaywall_json['host_type'],
        is_best: unpaywall_json['is_best'],
        license: unpaywall_json['license'],
        oa_date: unpaywall_json['oa_date'],
        source_updated_at: unpaywall_json['updated'],
        version: unpaywall_json['version']
      )
    end

    def build_new_oal(publication, url)
      publication.open_access_locations.build(source: Source::USER, url: url)
    end
end
