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

    def get_pub(url, attempts = 1)
      HTTParty.get(url).to_s
    rescue Net::ReadTimeout, Net::OpenTimeout
      attempts += 1
      if attempts <= 10
        get_pub(url, attempts)
      else
        raise
      end
    end

    def query_unpaywall_for(publication)
      unpaywall_json = nil
      find_url = URI::DEFAULT_PARSER.escape("https://api.unpaywall.org/v2/#{publication.doi_url_path}?email=openaccess@psu.edu")
      unpaywall_json = JSON.parse(get_pub(find_url))

      best_oa_location = unpaywall_json.dig('best_oa_location', 'url')
      existing_oa_location = publication.open_access_locations.find_by(source: Source::UNPAYWALL)
      oa_status = unpaywall_json['oa_status']

      if best_oa_location
        if existing_oa_location
          existing_oa_location.update!(url: best_oa_location)
        else
          publication.open_access_locations.create!(source: Source::UNPAYWALL, url: best_oa_location)
        end
      else
        existing_oa_location.try(:destroy)
      end

      publication.open_access_status = oa_status
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
