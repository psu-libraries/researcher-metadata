class OpenAccessButtonPublicationImporter
  def call
    pbar = ProgressBar.create(title: 'Importing publication data from Open Access Button',
                              total: pub_query.count) unless Rails.env.test?

    pub_query.find_each do |p|
      find_url = URI.encode("https://api.openaccessbutton.org/find?id=#{p.doi_url_path}")
      oab_json = JSON.parse(get_pub(find_url))

      p.open_access_url = oab_json['url'] if oab_json['url']
      p.open_access_button_last_checked_at = Time.current
      p.save!

      # Open Access Button does not enforce any rate limits for their API, but they ask
      # that users make no more than 1 request per second.
      sleep 1
      pbar.increment unless Rails.env.test?
    end
    pbar.finish unless Rails.env.test?
  end

  private

  def pub_query
    Publication.where.not(doi: nil).where.not(doi: '').where(%{open_access_url IS NULL OR open_access_url = ''})
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
end
