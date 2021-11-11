# frozen_string_literal: true

namespace :generate do
  task :journal_article_no_open_access_url, [:webaccess_id] => :environment do |_task, args|
    journal = Journal.find(rand(Journal.count))
    journal ||= FactoryBot.create :journal
    pub = FactoryBot.create :publication,
                            title: FFaker::Lorem.sentence,
                            secondary_title: FFaker::Lorem.sentence,
                            publication_type: Publication.publication_types.collect {|type| type if type.match(/Journal Article/)}.compact.sample,
                            journal: journal,
                            abstract: FFaker::Lorem.paragraph,
                            isbn: FFaker::Book.isbn,
                            volume: rand(50),
                            edition: rand(50),
                            doi: "https://doi.org/10.#{rand(1000..9999)}/#{FFaker::Internet.ip_v4_address}",
                            published_on: (Date.today - 6.months)
    pub.contributor_names << FactoryBot.create(:contributor_name,
                                               first_name: FFaker::Name.first_name,
                                               last_name: FFaker::Name.last_name)
    FactoryBot.create :authorship,
                      user: User.find_by(webaccess_id: args[:webaccess_id]),
                      publication: pub

    FactoryBot.create :publication_import,
                      source: 'Pure',
                      source_identifier: FFaker::Lorem.characters(50),
                      publication: pub
  end

  task :journal_article_with_open_access_url, [:webaccess_id] => :environment do |_task, args|
    journal = Journal.find(rand(Journal.count))
    journal ||= FactoryBot.create :journal
    pub = FactoryBot.create :publication,
                            title: FFaker::Lorem.sentence,
                            secondary_title: FFaker::Lorem.sentence,
                            publication_type: Publication.publication_types.collect {|type| type if type.match(/Journal Article/)}.compact.sample,
                            journal: journal,
                            abstract: FFaker::Lorem.paragraph,
                            isbn: FFaker::Book.isbn,
                            volume: rand(50),
                            edition: rand(50),
                            doi: "https://doi.org/10.#{rand(1000..9999)}/#{FFaker::Internet.ip_v4_address}",
                            published_on: (Date.today - 6.months)
    pub.contributor_names << FactoryBot.create(:contributor_name,
                                               first_name: FFaker::Name.first_name,
                                               last_name: FFaker::Name.last_name)
    pub.open_access_locations << FactoryBot.create(:open_access_location, url: FFaker::Internet.url)
    FactoryBot.create :authorship,
                      user: User.find_by(webaccess_id: args[:webaccess_id]),
                      publication: pub

    FactoryBot.create :publication_import,
                      source: 'Pure',
                      source_identifier: FFaker::Lorem.characters(50),
                      publication: pub
  end

  task :journal_article_in_press, [:webaccess_id] => :environment do |_task, args|
    journal = Journal.find(rand(Journal.count))
    journal ||= FactoryBot.create :journal
    pub = FactoryBot.create :publication,
                            title: FFaker::Lorem.sentence,
                            secondary_title: FFaker::Lorem.sentence,
                            publication_type: Publication.publication_types.collect {|type| type if type.match(/Journal Article/)}.compact.sample,
                            journal: journal,
                            abstract: FFaker::Lorem.paragraph,
                            isbn: FFaker::Book.isbn,
                            volume: rand(50),
                            edition: rand(50),
                            doi: "https://doi.org/10.#{rand(1000..9999)}/#{FFaker::Internet.ip_v4_address}",
                            published_on: (Date.today - 6.months),
                            status: 'In Press'
    pub.contributor_names << FactoryBot.create(:contributor_name,
                                               first_name: FFaker::Name.first_name,
                                               last_name: FFaker::Name.last_name)
    FactoryBot.create :authorship,
                      user: User.find_by(webaccess_id: args[:webaccess_id]),
                      publication: pub

    FactoryBot.create :publication_import,
                      source: 'Pure',
                      source_identifier: FFaker::Lorem.characters(50),
                      publication: pub
  end

  task :other_work, [:webaccess_id] => :environment do |_task, args|
    journal = Journal.find(rand(Journal.count))
    journal ||= FactoryBot.create :journal
    pub = FactoryBot.create :publication,
                            title: FFaker::Lorem.sentence,
                            secondary_title: FFaker::Lorem.sentence,
                            publication_type: Publication.publication_types.collect {|type| type if !type.match(/Journal Article/)}.compact.sample,
                            journal: journal,
                            abstract: FFaker::Lorem.paragraph,
                            isbn: FFaker::Book.isbn,
                            volume: rand(50),
                            edition: rand(50),
                            doi: "https://doi.org/10.#{rand(1000..9999)}/#{FFaker::Internet.ip_v4_address}",
                            published_on: (Date.today - 6.months)
    pub.contributor_names << FactoryBot.create(:contributor_name,
                                               first_name: FFaker::Name.first_name,
                                               last_name: FFaker::Name.last_name)
    FactoryBot.create :authorship,
                      user: User.find_by(webaccess_id: args[:webaccess_id]),
                      publication: pub

    FactoryBot.create :publication_import,
                      source: 'Pure',
                      source_identifier: FFaker::Lorem.characters(50),
                      publication: pub
  end

  task :journal_article_from_activity_insight, [:webaccess_id] => :environment do |_task, args|
    journal = Journal.find(rand(Journal.count))
    journal ||= FactoryBot.create :journal
    pub = FactoryBot.create :publication,
                            title: FFaker::Lorem.sentence,
                            secondary_title: FFaker::Lorem.sentence,
                            publication_type: Publication.publication_types.collect {|type| type if type.match(/Journal Article/)}.compact.sample,
                            journal: journal,
                            abstract: FFaker::Lorem.paragraph,
                            isbn: FFaker::Book.isbn,
                            volume: rand(50),
                            edition: rand(50),
                            doi: "https://doi.org/10.#{rand(1000..9999)}/#{FFaker::Internet.ip_v4_address}",
                            published_on: (Date.today - 6.months)
    pub.contributor_names << FactoryBot.create(:contributor_name,
                                               first_name: FFaker::Name.first_name,
                                               last_name: FFaker::Name.last_name)
    FactoryBot.create :authorship,
                      user: User.find_by(webaccess_id: args[:webaccess_id]),
                      publication: pub

    FactoryBot.create :publication_import,
                      source: 'Activity Insight',
                      source_identifier: rand(10000000..99999999),
                      publication: pub
  end

  task :journal_article_duplicate_group, [:webaccess_id] => :environment do |_task, args|
    journal = Journal.find(rand(Journal.count))
    journal ||= FactoryBot.create :journal
    dup_group = FactoryBot.create :duplicate_publication_group
    pub = FactoryBot.create :publication,
                            title: FFaker::Lorem.sentence,
                            secondary_title: FFaker::Lorem.sentence,
                            publication_type: Publication.publication_types.collect {|type| type if type.match(/Journal Article/)}.compact.sample,
                            journal: journal,
                            abstract: FFaker::Lorem.paragraph,
                            isbn: FFaker::Book.isbn,
                            volume: rand(50),
                            edition: rand(50),
                            doi: "https://doi.org/10.#{rand(1000..9999)}/#{FFaker::Internet.ip_v4_address}",
                            published_on: (Date.today - 6.months),
                            duplicate_publication_group_id: dup_group.id
    pub2 = pub.dup
    pub2.update visible: false
    pub2.save
    pub.contributor_names << FactoryBot.create(:contributor_name,
                                               first_name: FFaker::Name.first_name,
                                               last_name: FFaker::Name.last_name)
    FactoryBot.create :authorship,
                      user: User.find_by(webaccess_id: args[:webaccess_id]),
                      publication: pub

    FactoryBot.create :publication_import,
                      source: 'Pure',
                      source_identifier: FFaker::Lorem.characters(50),
                      publication: pub

    FactoryBot.create :publication_import,
                      source: 'Activity Insight',
                      source_identifier: rand(10000000..99999999),
                      publication: pub2
  end

  task :journal_article_non_duplicate_group, [:webaccess_id] => :environment do |_task, args|
    journal = Journal.find(rand(Journal.count))
    journal ||= FactoryBot.create :journal
    dup_group = FactoryBot.create :duplicate_publication_group
    non_dup_group = FactoryBot.create :non_duplicate_publication_group
    pub = FactoryBot.create :publication,
                            title: FFaker::Lorem.sentence,
                            secondary_title: FFaker::Lorem.sentence,
                            publication_type: Publication.publication_types.collect {|type| type if type.match(/Journal Article/)}.compact.sample,
                            journal: journal,
                            abstract: FFaker::Lorem.paragraph,
                            isbn: FFaker::Book.isbn,
                            volume: rand(50),
                            edition: rand(50),
                            doi: "https://doi.org/10.#{rand(1000..9999)}/#{FFaker::Internet.ip_v4_address}",
                            published_on: (Date.today - 6.months),
                            duplicate_publication_group_id: dup_group.id
    pub2 = pub.dup
    pub2.update visible: false
    pub2.save
    pub.contributor_names << FactoryBot.create(:contributor_name,
                                               first_name: FFaker::Name.first_name,
                                               last_name: FFaker::Name.last_name)
    FactoryBot.create :authorship,
                      user: User.find_by(webaccess_id: args[:webaccess_id]),
                      publication: pub

    FactoryBot.create :publication_import,
                      source: 'Pure',
                      source_identifier: FFaker::Lorem.characters(50),
                      publication: pub

    FactoryBot.create :publication_import,
                      source: 'Activity Insight',
                      source_identifier: rand(10000000..99999999),
                      publication: pub2

    FactoryBot.create :non_duplicate_publication_group_membership,
                      publication: pub,
                      non_duplicate_publication_group_id: non_dup_group.id

    FactoryBot.create :non_duplicate_publication_group_membership,
                      publication: pub2,
                      non_duplicate_publication_group_id: non_dup_group.id
  end

  task :presentation, [:webaccess_id] => :environment do |_task, args|
    pres = FactoryBot.create :presentation,
                             title: FFaker::Book.title,
                             activity_insight_identifier: rand(10000000..99999999),
                             name: FFaker::Conference.name,
                             organization: FFaker::Education.school,
                             location: "#{FFaker::AddressUS.city}, #{FFaker::AddressUS.state}, United States",
                             started_on: Date.today - 6.months,
                             ended_on: Date.tomorrow - 6.months,
                             presentation_type: 'Presentations',
                             meet_type: 'Academic',
                             refereed: 'Yes',
                             abstract: FFaker::Lorem.paragraph,
                             scope: 'National'

    FactoryBot.create :presentation_contribution,
                      user: User.find_by(webaccess_id: args[:webaccess_id]),
                      presentation: pres
  end

  task :performance, [:webaccess_id] => :environment do |_task, args|
    perf = FactoryBot.create :performance,
                             title: FFaker::Book.title,
                             activity_insight_id: rand(10000000..999999999),
                             performance_type: FFaker::Lorem.word,
                             sponsor: FFaker::Education.school,
                             description: FFaker::Lorem.paragraph,
                             group_name: FFaker::Music.artist,
                             location: "#{FFaker::AddressUS.city}, #{FFaker::AddressUS.state}, United States",
                             start_on: Date.today - 6.months,
                             end_on: Date.tomorrow - 6.months,
                             delivery_type: 'Invitation',
                             scope: 'National'

    FactoryBot.create :user_performance,
                      activity_insight_id: perf.activity_insight_id,
                      user: User.find_by(webaccess_id: args[:webaccess_id]),
                      performance: perf
  end
end
