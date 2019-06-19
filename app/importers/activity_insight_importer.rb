class ActivityInsightImporter
  def initialize
    @errors = []
  end

  attr_reader :errors

  def call
    pbar = ProgressBar.create(title: 'Importing Activity Insight Data', total: ai_users.count) unless Rails.env.test?

    ai_users.each do |aiu|
      pbar.increment unless Rails.env.test?
      u = User.find_by(webaccess_id: aiu.webaccess_id) || User.new

      if u.new_record? || (u.persisted? && u.updated_by_user_at.blank?)
        begin
          details = ai_user_detail(aiu.raw_webaccess_id)

          u.first_name = aiu.first_name
          u.middle_name = aiu.middle_name
          u.last_name = aiu.last_name
          u.webaccess_id = aiu.webaccess_id
          u.penn_state_identifier = aiu.penn_state_id
          u.activity_insight_identifier = aiu.activity_insight_id

          u.ai_building = details.building
          u.ai_alt_name = details.alt_name
          u.ai_room_number = details.room_number
          u.ai_office_area_code = details.office_phone_1
          u.ai_office_phone_1 = details.office_phone_2
          u.ai_office_phone_2 = details.office_phone_3
          u.ai_fax_area_code = details.fax_1
          u.ai_fax_1 = details.fax_2
          u.ai_fax_2 = details.fax_3
          u.ai_website = details.website
          u.ai_bio = details.bio
          u.ai_teaching_interests = details.teaching_interests
          u.ai_research_interests = details.research_interests

          u.save!
        rescue Exception => e
          errors << e
        end
      end
    end

    pbar.finish unless Rails.env.test?
  end

  private

  def ai_users
    @users ||= Nokogiri::XML(ai_users_xml).css('Users User').map { |u| ActivityInsightListUser.new(u) }
  end

  def ai_users_xml
    @xml ||= HTTParty.get('https://webservices.digitalmeasures.com/login/service/v4/User',
                          basic_auth: {username: Rails.configuration.x.activity_insight['username'],
                                       password: Rails.configuration.x.activity_insight['password']}).to_s
  end

  def ai_user_detail_xml(id)
    HTTParty.get("https://webservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University/USERNAME:#{id}",
                 basic_auth: {username: Rails.configuration.x.activity_insight['username'],
                              password: Rails.configuration.x.activity_insight['password']}).to_s
  end

  def ai_user_detail(id)
    ActivityInsightDetailUser.new(Nokogiri::XML(ai_user_detail_xml(id)))
  end
end


class ActivityInsightListUser
  def initialize(parsed_user)
    @parsed_user = parsed_user
  end

  def raw_webaccess_id
    parsed_user.attribute('username').value
  end

  def webaccess_id
    raw_webaccess_id.downcase
  end

  def activity_insight_id
    parsed_user.attribute('userId').value
  end

  def penn_state_id
    parsed_user.attribute('PSUIDFacultyOnly').value if parsed_user.attribute('PSUIDFacultyOnly')
  end

  def first_name
    parsed_user.css('FirstName').text.strip.presence
  end

  def middle_name
    parsed_user.css('MiddleName').text.strip.presence
  end

  def last_name
    parsed_user.css('LastName').text.strip.presence
  end

  private

  attr_reader :parsed_user
end


class ActivityInsightDetailUser
  def initialize(parsed_user)
    @parsed_user = parsed_user
  end

  def webaccess_id
    user.attribute('username').value.downcase
  end

  def alt_name
    contact_info.css('ALT_NAME').text.strip.presence
  end

  def building
    contact_info.css('BUILDING').text.strip.presence
  end

  def room_number
    contact_info.css('ROOMNUM').text.strip.presence
  end

  def office_phone_1
    contact_info.css('OPHONE1').text.strip.presence
  end

  def office_phone_2
    contact_info.css('OPHONE2').text.strip.presence
  end

  def office_phone_3
    contact_info.css('OPHONE3').text.strip.presence
  end

  def fax_1
    contact_info.css('FAX1').text.strip.presence
  end

  def fax_2
    contact_info.css('FAX2').text.strip.presence
  end

  def fax_3
    contact_info.css('FAX3').text.strip.presence
  end

  def website
    contact_info.css('WEBSITE').text.strip.presence
  end

  def bio
    user.css('BIO').text.strip.presence
  end

  def teaching_interests
    user.css('TEACHING_INTERESTS').text.strip.presence
  end

  def research_interests
    user.css('RESEARCH_INTERESTS').text.strip.presence
  end

  def publications
    user.css('INTELLCONT').map { |p| ActivityInsightPublication.new(p) }
  end

  private

  attr_reader :parsed_user

  def user
    parsed_user.css('Data Record')
  end

  def contact_info
    user.css('PCI')
  end
end


class ActivityInsightPublication
  def initialize(parsed_publication)
    @parsed_publication = parsed_publication
  end

  def title
    parsed_publication.css('TITLE').text.strip.presence
  end

  def type
    if parsed_publication.css('CONTYPE').text.empty?
      parsed_publication.css('CONTYPEOTHER').text.strip.presence
    else
      parsed_publication.css('CONTYPE').text.strip.presence
    end
  end

  private

  attr_reader :parsed_publication
end