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
      Publication.all
    end

    def new_pubs
      all_pubs.where(unpaywall_last_checked_at: nil)
    end

    def import_from_unpaywall(publication)
      unpaywall_response = UnpaywallClient.query_unpaywall(publication)
      publication.update_from_unpaywall(unpaywall_response)

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
          unpaywall_response: unpaywall_response.to_s
        }
      )
    end
end
