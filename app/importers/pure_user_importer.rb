class PureUserImporter
  def initialize(filename: filename)
    @filename = filename
    @errors = []
  end

  def call
    json = MultiJson.load(file)
    json['items'].each do |user|
      first_and_middle_name = user['name']['firstName']
      first_name = first_and_middle_name.split(' ')[0].try(:strip)
      middle_name = first_and_middle_name.split(' ')[1].try(:strip)
      webaccess_id = user['externalId'].downcase

      u = User.find_by(webaccess_id: webaccess_id) || User.new
      u.first_name = first_name unless u.first_name.present?
      u.middle_name = middle_name unless u.middle_name.present?
      u.last_name = user['name']['lastName'] unless u.last_name.present?
      u.institution = 'Penn State University' unless u.institution.present?
      u.webaccess_id = webaccess_id unless u.webaccess_id.present?
      u.pure_uuid = user['uuid'] unless u.pure_uuid.present?

      u.save!
    end
    nil
  end

  private

  def file
    File.open(filename, 'r')
  end

  attr_reader :filename
end