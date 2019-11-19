class OpenAccessButtonPublicationImporter
  def call
    pbar = ProgressBar.create(title: 'Importing publication data from Open Access Button',
                              total: pub_query.count) unless Rails.env.test?

    pub_query.find_each do |p|
      find_url = "https://api.openaccessbutton.org/find?id=#{p.doi_url_path}"
      oab_json = JSON.parse(HTTParty.get(find_url).to_s)

      available_article = oab_json['data']['availability'].detect { |a| a['type'] == "article" }
      p.open_access_url = available_article['url'] if available_article
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
    Publication.where.not(doi: nil).where.not(doi: '').where(open_access_url: nil).
      where('open_access_button_last_checked_at IS NULL OR open_access_button_last_checked_at < ?', 1.week.ago)
  end
end
