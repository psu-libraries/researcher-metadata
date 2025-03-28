# frozen_string_literal: true

class PureUserImporter < PureImporter
  def call
    pbar = Utilities::ProgressBarTTY.create(title: 'Importing Pure persons (users)', total: total_pages)

    1.upto(total_pages) do |i|
      offset = (i - 1) * page_size
      persons = get_records(type: record_type, page_size: page_size, offset: offset)

      persons['items'].each do |item|
        if item['externalId'].present?
          first_and_middle_name = item['name']['firstName']
          first_name = first_and_middle_name.split[0].try(:strip)
          middle_name = first_and_middle_name.split[1].try(:strip)
          webaccess_id = item['externalId'].downcase

          u = User.find_by(webaccess_id: webaccess_id) || User.new

          u.scopus_h_index = item['scopusHIndex']
          u.pure_uuid = item['uuid']

          # The identity service imports should be the authority on
          # names so only import names for new records.
          if u.new_record?
            u.first_name = first_name
            u.middle_name = middle_name
            u.last_name = item['name']['lastName']
            u.webaccess_id = webaccess_id
          end

          u.save!

          item['staffOrganisationAssociations']&.each do |a|
            o_uuid = a['organisationalUnit']['uuid']

            o = o_uuid ? Organization.find_by(pure_uuid: o_uuid) : nil

            if o
              m = UserOrganizationMembership.find_by(source_identifier: a['pureId'], import_source: 'Pure') ||
                UserOrganizationMembership.find_by(user: u, organization: o, started_on: a['period']['startDate'], import_source: 'HR') ||
                UserOrganizationMembership.new

              m.import_source = 'Pure'
              m.source_identifier = a['pureId']
              m.organization = o
              m.user = u
              m.primary = a['isPrimaryAssociation']
              m.position_title = position_title(a)
              m.started_on = a['period']['startDate']
              m.ended_on = a['period']['endDate']
              m.save!
            end
          end
        end
      rescue StandardError => e
        log_error(e, {
                    user_id: u&.id,
                    item: item
                  })
      end
      pbar.increment
    rescue StandardError => e
      log_error(e, {})
    end
    pbar.finish
  rescue StandardError => e
    log_error(e, {})
  end

  def page_size
    100
  end

  def record_type
    'persons'
  end

  private

    def position_title(association)
      association['jobDescription'] && association['jobDescription']['text'].find { |text| text['locale'] == 'en_US' }['value']
    end
end
