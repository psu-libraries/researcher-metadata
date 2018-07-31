class PureUserImporter
  def initialize(filename:)
    @filename = filename
    @errors = []
  end

  def call
    json = MultiJson.load(file)
    pbar = ProgressBar.create(title: 'Importing Pure users', total: json['items'].count) unless Rails.env.test?

    json['items'].each do |user|
      pbar.increment unless Rails.env.test?
      first_and_middle_name = user['name']['firstName']
      first_name = first_and_middle_name.split(' ')[0].try(:strip)
      middle_name = first_and_middle_name.split(' ')[1].try(:strip)
      webaccess_id = user['externalId'].downcase

      u = User.find_by(webaccess_id: webaccess_id) || User.new

      # Create the user with Pure data if we don't have a record at all, and update
      # it with new Pure data if we've never imported the user from Activity Insight,
      # but we assume that Activity Insight is a better source of user data, so
      # we don't overwrite AI data with data from Pure.
      if u.new_record? || u.activity_insight_identifier.blank?
        u.first_name = first_name
        u.middle_name = middle_name
        u.last_name = user['name']['lastName']
        u.institution = 'Penn State University'
        u.webaccess_id = webaccess_id if u.new_record?
        u.pure_uuid = user['uuid']
        u.save!
      end
    end
    pbar.finish unless Rails.env.test?
    nil
  end

  private

  def file
    File.open(filename, 'r')
  end

  attr_reader :filename
end