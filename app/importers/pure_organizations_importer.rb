# frozen_string_literal: true

class PureOrganizationsImporter < PureImporter
  def call
    pbar = ProgressBar.create(title: 'Importing Pure organisational-units (organizations)', total: total_pages) unless Rails.env.test?
    1.upto(total_pages) do |i|
      offset = (i - 1) * page_size
      organizations = get_records(type: record_type, page_size: page_size, offset: offset)

      organizations['items'].each do |item|
        o = Organization.find_by(pure_uuid: item['uuid']) || Organization.new

        o.pure_uuid = item['uuid'] if o.new_record?
        o.name = extract_name(item)
        o.pure_external_identifier = item['externalId']
        o.organization_type = extract_organization_type(item)
        o.save!
      rescue StandardError => e
        log_error(e, {
                    record_type: record_type,
                    organization_id: o&.id,
                    item: item
                  })
      end
      pbar.increment unless Rails.env.test?

    rescue StandardError => e
      log_error(e, {
                  record_type: record_type,
                  organizations: organizations
                })
    end
    pbar.finish unless Rails.env.test?

    pbar = ProgressBar.create(title: 'Importing Pure organization relationships', total: total_pages) unless Rails.env.test?
    1.upto(total_pages) do |i|
      offset = (i - 1) * page_size
      organizations = get_records(type: record_type, page_size: page_size, offset: offset)

      organizations['items'].each do |item|
        child_org = Organization.find_by(pure_uuid: item['uuid'])
        parent_org = if item['parents']
                       Organization.find_by(pure_uuid: item['parents'].first['uuid'])
                     end

        child_org.parent = parent_org
        child_org.save!
      rescue StandardError => e
        log_error(e, {
                    record_type: record_type,
                    child_org_id: child_org&.id,
                    parent_org_id: parent_org&.id,
                    item: item
                  })
      end
      pbar.increment unless Rails.env.test?

    rescue StandardError => e
      log_error(e, {
                  record_type: record_type,
                  organizations: organizations
                })
    end
    pbar.finish unless Rails.env.test?
  rescue StandardError => e
    log_error(e, {})
  end

  def page_size
    1000
  end

  def record_type
    'organisational-units'
  end

  private

    def extract_name(org)
      org['name']['text'].find { |text| text['locale'] == 'en_US' }['value']
    end

    def extract_organization_type(org)
      org['type']['term']['text'].find { |text| text['locale'] == 'en_US' }['value']
    end
end
