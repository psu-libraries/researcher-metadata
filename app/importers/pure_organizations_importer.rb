class PureOrganizationsImporter
  def initialize(filename:)
    @filename = filename
    @errors = []
  end

  def call
    File.open(filename, 'r') do |file|
      json = MultiJson.load(file)
      pbar = ProgressBar.create(title: 'Importing Pure organizations', total: json['items'].count) unless Rails.env.test?

      json['items'].each do |org|
        pbar.increment unless Rails.env.test?

        o = Organization.find_by(pure_uuid: org['uuid']) || Organization.new

        o.pure_uuid = org['uuid'] if o.new_record?
        o.name = org['name'].first['value']
        o.pure_external_identifier = org['externalId']
        o.organization_type = org['type'].first['value']
        o.save!
      end
      pbar.finish unless Rails.env.test?

      pbar = ProgressBar.create(title: 'Importing Pure organization relationships', total: json['items'].count) unless Rails.env.test?

      json['items'].each do |org|
        pbar.increment unless Rails.env.test?

        child_org = Organization.find_by(pure_uuid: org['uuid'])
        if org['parents']
          parent_org = Organization.find_by(pure_uuid: org['parents'].first['uuid'])
        else
          parent_org = nil
        end

        child_org.parent = parent_org
        child_org.save!
      end
      pbar.finish unless Rails.env.test?
    end
    nil
  end

  private

  attr_reader :filename
end