class OpenAccessButtonPublicationImporter
  def import_all
    pbar = ProgressBar.create(title: 'Importing publication data from Open Access Button',
                              total: all_pubs.count) unless Rails.env.test?

    all_pubs.find_each do |p|
      query_open_access_button_for(p)
      pbar.increment unless Rails.env.test?
    end
    pbar.finish unless Rails.env.test?
  end

  def import_new
    pbar = ProgressBar.create(title: 'Importing publication data from Open Access Button',
                              total: new_pubs.count) unless Rails.env.test?

    new_pubs.find_each do |p|
      query_open_access_button_for(p)
      pbar.increment unless Rails.env.test?
    end
    pbar.finish unless Rails.env.test?
  end

  private

  def all_pubs
    Publication.where.not(doi: nil).where.not(doi: '').where(%{open_access_url IS NULL OR open_access_url = ''})
  end

  def new_pubs
    all_pubs.where(open_access_button_last_checked_at: nil)
  end

  def get_pub(url)
    attempts = 0
    HTTParty.get(url).to_s
  rescue Net::ReadTimeout, Net::OpenTimeout
    if attempts <= 10
      attempts += 1
      retry
    else
      raise
    end
  end

  def query_open_access_button_for(publication)
    find_url = URI.encode("https://api.openaccessbutton.org/find?id=#{publication.doi_url_path}")
    oab_json = JSON.parse(get_pub(find_url))

    publication.open_access_url = oab_json['url'] if oab_json['url']
    publication.open_access_button_last_checked_at = Time.current
    publication.save!

    # Open Access Button does not enforce any rate limits for their API, but they ask
    # that users make no more than 1 request per second.
    sleep 1
  end
end
