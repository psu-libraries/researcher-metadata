# frozen_string_literal: true

namespace :generate do
  task :journal_article_no_oa_url, [:webaccess_id] => :environment do |_task, args|
    journal = Journal.find(rand(Journal.count))
    journal ||= FactoryBot.create :journal
    pub = FactoryBot.create :publication,
                            title: FFaker::BaconIpsum.sentence,
                            secondary_title: FFaker::FreedomIpsum.sentence,
                            publication_type: 'Journal Article',
                            journal: journal,
                            abstract: FFaker::HipsterIpsum.paragraph,
                            published_on: (Date.today - 6.months)
    pub.contributor_names << FactoryBot.create(:contributor_name,
                                               first_name: FFaker::Name.first_name,
                                               last_name: FFaker::Name.last_name)
    FactoryBot.create :authorship,
                      user: User.find_by(webaccess_id: args[:webaccess_id]),
                      publication: pub
  end

  task :journal_article_w_oa_url, [:webaccess_id] => :environment do |_task, args|
    journal = Journal.find(rand(Journal.count))
    journal ||= FactoryBot.create :journal
    pub = FactoryBot.create :publication,
                            title: FFaker::BaconIpsum.sentence,
                            secondary_title: FFaker::FreedomIpsum.sentence,
                            publication_type: 'Journal Article',
                            journal: journal,
                            abstract: FFaker::HipsterIpsum.paragraph,
                            published_on: (Date.today - 6.months)
    pub.contributor_names << FactoryBot.create(:contributor_name,
                                               first_name: FFaker::Name.first_name,
                                               last_name: FFaker::Name.last_name)
    pub.open_access_locations << FactoryBot.create(:open_access_location)
    FactoryBot.create :authorship,
                      user: User.find_by(webaccess_id: args[:webaccess_id]),
                      publication: pub
  end

  task :journal_article_in_press, [:webaccess_id] => :environment do |_task, args|
    journal = Journal.find(rand(Journal.count))
    journal ||= FactoryBot.create :journal
    pub = FactoryBot.create :publication,
                            title: FFaker::BaconIpsum.sentence,
                            secondary_title: FFaker::FreedomIpsum.sentence,
                            publication_type: 'Journal Article',
                            journal: journal,
                            abstract: FFaker::HipsterIpsum.paragraph,
                            published_on: (Date.today - 6.months),
                            status: 'In Press'
    pub.contributor_names << FactoryBot.create(:contributor_name,
                                               first_name: FFaker::Name.first_name,
                                               last_name: FFaker::Name.last_name)
    FactoryBot.create :authorship,
                      user: User.find_by(webaccess_id: args[:webaccess_id]),
                      publication: pub
  end

  task :other_work, [:webaccess_id] => :environment do |_task, args|
    journal = Journal.find(rand(Journal.count))
    journal ||= FactoryBot.create :journal
    pub = FactoryBot.create :publication,
                            title: FFaker::BaconIpsum.sentence,
                            secondary_title: FFaker::FreedomIpsum.sentence,
                            publication_type: 'Letter',
                            journal: journal,
                            abstract: FFaker::HipsterIpsum.paragraph,
                            published_on: (Date.today - 6.months)
    pub.contributor_names << FactoryBot.create(:contributor_name,
                                               first_name: FFaker::Name.first_name,
                                               last_name: FFaker::Name.last_name)
    FactoryBot.create :authorship,
                      user: User.find_by(webaccess_id: args[:webaccess_id]),
                      publication: pub
  end

  task :presentation, [:webaccess_id] => :environment do |_task, args|
  end

  task :performance, [:webaccess_id] => :environment do |_task, args|
  end
end
