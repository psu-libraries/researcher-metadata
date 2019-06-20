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

          details.education_history_items.each do |item|
            i = EducationHistoryItem.find_by(activity_insight_identifier: item.activity_insight_id) ||
              EducationHistoryItem.new

            i.activity_insight_identifier = item.activity_insight_id if i.new_record?
            i.user = u
            i.degree = item.degree
            i.explanation_of_other_degree = item.explanation_of_other_degree
            i.institution = item.institution
            i.school = item.school
            i.location_of_institution = item.location_of_institution
            i.emphasis_or_major = item.emphasis_or_major
            i.supporting_areas_of_emphasis = item.supporting_areas_of_emphasis
            i.dissertation_or_thesis_title = item.dissertation_or_thesis_title
            i.is_highest_degree_earned = item.is_highest_degree_earned
            i.honor_or_distinction = item.honor_or_distinction
            i.description = item.description
            i.comments = item.comments
            i.start_year = item.start_year
            i.end_year = item.end_year
            i.save!
          end
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
    value_for('username')
  end

  def webaccess_id
    raw_webaccess_id.downcase
  end

  def activity_insight_id
    value_for('userId')
  end

  def penn_state_id
    value_for('PSUIDFacultyOnly') if parsed_user.attribute('PSUIDFacultyOnly')
  end

  def first_name
    text_for('FirstName')
  end

  def middle_name
    text_for('MiddleName')
  end

  def last_name
    text_for('LastName')
  end

  private

  attr_reader :parsed_user

  def text_for(element)
    parsed_user.css(element).text.strip.presence
  end

  def value_for(attribute)
    parsed_user.attribute(attribute).value
  end
end


class ActivityInsightDetailUser
  def initialize(parsed_user)
    @parsed_user = parsed_user
  end

  def webaccess_id
    user.attribute('username').value.downcase
  end

  def alt_name
    contact_info_text_for('ALT_NAME')
  end

  def building
    contact_info_text_for('BUILDING')
  end

  def room_number
    contact_info_text_for('ROOMNUM')
  end

  def office_phone_1
    contact_info_text_for('OPHONE1')
  end

  def office_phone_2
    contact_info_text_for('OPHONE2')
  end

  def office_phone_3
    contact_info_text_for('OPHONE3')
  end

  def fax_1
    contact_info_text_for('FAX1')
  end

  def fax_2
    contact_info_text_for('FAX2')
  end

  def fax_3
    contact_info_text_for('FAX3')
  end

  def website
    contact_info_text_for('WEBSITE')
  end

  def bio
    user_text_for('BIO')
  end

  def teaching_interests
    user_text_for('TEACHING_INTERESTS')
  end

  def research_interests
    user_text_for('RESEARCH_INTERESTS')
  end

  def education_history_items
    user.css('EDUCATION').map { |p| ActivityInsightEducationHistoryItem.new(p) }
  end

  private

  attr_reader :parsed_user

  def user
    parsed_user.css('Data Record')
  end

  def contact_info
    user.css('PCI')
  end

  def contact_info_text_for(element)
    contact_info.css(element).text.strip.presence
  end

  def user_text_for(element)
    user.css(element).text.strip.presence
  end
end


class ActivityInsightEducationHistoryItem
  def initialize(parsed_item)
    @parsed_item = parsed_item
  end

  def activity_insight_id
    parsed_item.attribute('id').value
  end

  def degree
    text_for('DEG')
  end

  def explanation_of_other_degree
    text_for('DEGOTHER')
  end

  def is_highest_degree_earned
    text_for('HIGHEST')
  end

  def institution
    text_for('SCHOOL')
  end

  def school
    text_for('COLLEGE')
  end

  def location_of_institution
    text_for('LOCATION')
  end

  def emphasis_or_major
    text_for('MAJOR')
  end

  def supporting_areas_of_emphasis
    text_for('SUPPAREA')
  end

  def dissertation_or_thesis_title
    text_for('DISSTITLE')
  end

  def honor_or_distinction
    text_for('DISTINCTION')
  end

  def description
    text_for('DESC')
  end

  def comments
    text_for('COMMENT')
  end

  def start_year
    text_for('DTY_START')
  end

  def end_year
    text_for('DTY_END')
  end

  private

  attr_reader :parsed_item

  def text_for(element)
    parsed_item.css(element).text.strip.presence
  end
end