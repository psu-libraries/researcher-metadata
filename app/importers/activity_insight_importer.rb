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
      details = ai_user_detail(aiu.raw_webaccess_id)

      begin
        if u.new_record? || (u.persisted? && u.updated_by_user_at.blank?)
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
        end

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

        details.presentations.each do |pres|
          p = Presentation.find_by(activity_insight_identifier: pres.activity_insight_id) ||
            Presentation.new

          if p.new_record? || (p.persisted? && p.updated_by_user_at.blank?)
            p.activity_insight_identifier = pres.activity_insight_id if p.new_record?
            p.title = pres.title
            p.name = pres.name
            p.organization = pres.organization
            p.location = pres.location
            p.presentation_type = pres.type
            p.meet_type = pres.meet_type
            p.scope = pres.scope
            p.attendance = pres.attendance
            p.refereed = pres.refereed
            p.abstract = pres.abstract
            p.comment = pres.comment

            p.save!
          end

          pres.contributors.each_with_index do |cont, index|
            if cont.activity_insight_user_id
              contributor = User.find_by(activity_insight_identifier: cont.activity_insight_user_id)

              if contributor
                c = PresentationContribution.find_by(activity_insight_identifier: cont.activity_insight_id) ||
                  PresentationContribution.new

                c.activity_insight_identifier = cont.activity_insight_id if c.new_record?
                c.user = contributor
                c.presentation = p
                c.role = cont.role
                c.position = index + 1

                c.save!
              end
            end
          end
        end

        details.performances.each do |perf|
          p = Performance.find_by(activity_insight_id: perf.activity_insight_id) || Performance.new

          if p.new_record? || (p.persisted? && p.updated_by_user_at.blank?)
            p.activity_insight_id = perf.activity_insight_id if p.new_record?
            p.title = perf.title
            p.performance_type = perf.type
            p.sponsor = perf.sponsor
            p.description = perf.description
            p.group_name = perf.name
            p.location = perf.location
            p.delivery_type = perf.delivery_type
            p.scope = perf.scope
            p.start_on = perf.start_on
            p.end_on = perf.end_on

            p.save!
          end

          perf.contributors.each do |cont|
            if cont.activity_insight_user_id
              contributor = User.find_by(activity_insight_identifier: cont.activity_insight_user_id)

              if contributor
                up = UserPerformance.find_by(activity_insight_id: cont.activity_insight_id) ||
                  UserPerformance.new

                up.activity_insight_id = cont.activity_insight_id if up.new_record?
                up.user = contributor
                up.performance = p
                up.contribution = cont.contribution

                up.save!
              end
            end
          end
        end

      rescue Exception => e
        errors << e
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
    user.css('EDUCATION').map { |i| ActivityInsightEducationHistoryItem.new(i) }
  end

  def presentations
    user.css('PRESENT').map { |p| ActivityInsightPresentation.new(p) }
  end

  def performances
    user.css('PERFORM_EXHIBIT').map { |p| ActivityInsightPerformance.new(p) }
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


class ActivityInsightPresentation
  def initialize(parsed_presentation)
    @parsed_presentation = parsed_presentation
  end

  def activity_insight_id
    parsed_presentation.attribute('id').value
  end

  def title
    text_for('TITLE')
  end

  def name
    text_for('NAME')
  end

  def organization
    parsed_presentation.>('ORG').text.strip.presence
  end

  def location
    text_for('LOCATION')
  end

  def type
    if text_for('TYPE') && text_for('TYPE') != 'Other'
      text_for('TYPE')
    else
      text_for('TYPE_OTHER')
    end
  end

  def meet_type
    text_for('MEETTYPE')
  end

  def attendance
    text_for('ATTENDANCE')
  end

  def refereed
    text_for('REFEREED')
  end

  def abstract
    text_for('ABSTRACT')
  end

  def comment
    text_for('COMMENT')
  end

  def scope
    text_for('SCOPE')
  end

  def contributors
    parsed_presentation.css('PRESENT_AUTH').map do |c|
      ActivityInsightPresentationContributor.new(c)
    end
  end

  private

  attr_reader :parsed_presentation

  def text_for(element)
    parsed_presentation.css(element).text.strip.presence
  end
end


class ActivityInsightPresentationContributor
  def initialize(parsed_contributor)
    @parsed_contributor = parsed_contributor
  end

  def activity_insight_id
    parsed_contributor.attribute('id').value
  end

  def activity_insight_user_id
    text_for('FACULTY_NAME')
  end
  
  def role
    if text_for('ROLE') && text_for('ROLE') != 'Other'
      text_for('ROLE')
    else
      text_for('ROLE_OTHER')
    end
  end

  private

  attr_reader :parsed_contributor

  def text_for(element)
    parsed_contributor.css(element).text.strip.presence
  end
end


class ActivityInsightPerformance
  def initialize(parsed_performance)
    @parsed_performance = parsed_performance
  end

  def activity_insight_id
    parsed_performance.attribute('id').value
  end

  def title
    text_for('TITLE')
  end

  def type
    if text_for('TYPE') && text_for('TYPE') != 'Other'
      text_for('TYPE')
    else
      text_for('TYPE_OTHER')
    end
  end

  def sponsor
    text_for('SPONSOR')
  end

  def description
    text_for('DESC')
  end

  def name
    text_for('NAME')
  end

  def location
    text_for('LOCATION')
  end

  def delivery_type
    text_for('DELIVERY_TYPE')
  end

  def scope
    text_for('SCOPE')
  end

  def start_on
    text_for('START_START')
  end

  def end_on
    text_for('END_START')
  end

  def contributors
    parsed_performance.css('PERFORM_EXHIBIT_CONTRIBUTERS').map do |c|
      ActivityInsightPerformanceContributor.new(c)
    end
  end

  private

  attr_reader :parsed_performance

  def text_for(element)
    parsed_performance.css(element).text.strip.presence
  end
end


class ActivityInsightPerformanceContributor
  def initialize(parsed_contributor)
    @parsed_contributor = parsed_contributor
  end

  def activity_insight_id
    parsed_contributor.attribute('id').value
  end

  def activity_insight_user_id
    text_for('FACULTY_NAME')
  end

  def contribution
    text_for('CONTRIBUTION')
  end

  private

  attr_reader :parsed_contributor

  def text_for(element)
    parsed_contributor.css(element).text.strip.presence
  end
end
