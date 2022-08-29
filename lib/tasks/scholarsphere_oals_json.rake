# frozen_string_literal: true

desc 'Import Scholarsphere OALs from JSON
      Used for getting lost OALs from RMD backups'

task no_doi_scholarsphere_oals_to_json: :environment do
  File.write("#{Rails.root}/tmp/scholarsphere_oals.json", ScholarsphereWorkDeposit.where(doi: '').map { |s| s.publication.open_access_locations.where(source: 'scholarsphere') }.flatten.uniq.to_json)
end

task import_scholarsphere_oals_json: :environment do
  file = File.read("#{Rails.root}/tmp/scholarsphere_oals.json")
  json = JSON.parse(file)
  json.each do |oal|
    OpenAccessLocation.create(oal.except('source').merge('source' => 'scholarsphere'))
  rescue ActiveRecord::RecordNotUnique
    next
  end
end
