# frozen_string_literal: true

class OpenAccessButtonPublicationImporter
  def import_all
    pbar = ProgressBarTTY.create(title: 'Importing publication data from Open Access Button',
                                 total: all_pubs.count)

    all_pubs.find_each do |p|
      query_open_access_button_for(p)
      pbar.increment
    end
    pbar.finish
  end

  def import_new
    pbar = ProgressBarTTY.create(title: 'Importing publication data from Open Access Button',
                                 total: new_pubs.count)

    new_pubs.find_each do |p|
      query_open_access_button_for(p)
      pbar.increment
    end
    pbar.finish
  end

  def import_with_doi
    pbar = ProgressBarTTY.create(title: 'Importing publication data from Open Access Button',
                                 total: doi_pubs.count)

    doi_pubs.find_each do |p|
      query_open_access_button_for(p)
      pbar.increment
    end
    pbar.finish
  end

  def import_without_doi
    pbar = ProgressBarTTY.create(title: 'Importing publication data from Open Access Button',
                                 total: no_doi_pubs.count)

    no_doi_pubs.find_each do |p|
      query_open_access_button_for(p)
      pbar.increment
      sleep 1
    end
    pbar.finish
  end

  private

    def all_pubs
      Publication.all
    end

    def new_pubs
      all_pubs.where(open_access_button_last_checked_at: nil)
    end

    def doi_pubs
      all_pubs.where("doi IS NOT NULL AND doi <> ''")
    end

    def no_doi_pubs
      all_pubs.where("doi IS NULL OR doi = ''")
    end

    def query_open_access_button_for(publication)
      oab_json = nil
      find_url = if publication.doi.present?
                   "https://api.openaccessbutton.org/find?id=#{CGI.escape(publication.doi_url_path)}"
                 else
                   "https://api.openaccessbutton.org/find?title=#{CGI.escape(cleaned_title(publication))}"
                 end
      oab_json = JSON.parse(HttpService.get(find_url))

      existing_oa_location = publication.open_access_locations.find_by(source: Source::OPEN_ACCESS_BUTTON)

      publication.doi = DOISanitizer.new(oab_json['metadata']['doi']).url if publication.doi.blank?

      if oab_json['url']
        if existing_oa_location
          existing_oa_location.update!(url: oab_json['url'])
        else
          publication.open_access_locations.create!(source: Source::OPEN_ACCESS_BUTTON, url: oab_json['url'])
        end
      else
        existing_oa_location.try(:destroy)
      end

      publication.open_access_button_last_checked_at = Time.zone.now
      publication.save!

      # Open Access Button does not enforce any rate limits for their API, but they ask
      # that users make no more than 1 request per second.
      sleep 1 unless Rails.env.test?
    rescue StandardError => e
      ImporterErrorLog.log_error(
        importer_class: self.class,
        error: e,
        metadata: {
          publication_id: publication&.id,
          publication_doi_url_path: publication&.doi_url_path,
          oab_json: oab_json.to_s
        }
      )
    end

    # Open Access Button will block requests that they detect as "bot behavior"
    # We strip some characters here to not get flagged as a bot and blocked
    def cleaned_title(publication)
      publication.title.tr("'\"", '')
    end
end
