# frozen_string_literal: true

class WorksGenerator
  def initialize(webaccess_id)
    raise ArgumentError, 'No Webaccess ID supplied' if webaccess_id.blank?

    @user = User.find_by(webaccess_id: webaccess_id)
  end

  def journal_article_no_open_access_location
    FactoryBot.create :sample_publication, :journal_article, :from_pure, user: user
  end

  def journal_article_with_open_access_location
    FactoryBot.create :sample_publication, :journal_article, :from_pure, :with_open_access_location, user: user
  end

  def journal_article_in_press
    FactoryBot.create :sample_publication, :journal_article, :from_pure, :in_press, user: user
  end

  def journal_article_from_activity_insight
    FactoryBot.create :sample_publication, :journal_article, :from_activity_insight, user: user
  end

  def journal_article_duplicate_group
    FactoryBot.create :sample_publication, :journal_article, :from_pure, :with_duplicate_group, user: user
  end

  def journal_article_non_duplicate_group
    FactoryBot.create :sample_publication, :journal_article, :from_pure, :with_non_duplicate_group, user: user
  end

  def other_work
    FactoryBot.create :sample_publication, :other_work, :from_pure, user: user
  end

  def presentation
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
                      user: user,
                      presentation: pres
  end

  def performance
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
                      user: user,
                      performance: perf
  end

  private

    def create_duplicate_publication(publication)
      duplicate = publication.dup
      duplicate.update({ visible: false, duplicate_publication_group_id: publication.duplicate_publication_group_id })
      duplicate.save
      duplicate
    end

    def create_contributor_name(publication)
      FactoryBot.create(:contributor_name,
                        first_name: FFaker::Name.first_name,
                        last_name: FFaker::Name.last_name,
                        publication: publication)
    end

    def create_non_duplicate_group_membership(publication, non_duplicate_group_id)
      FactoryBot.create :non_duplicate_publication_group_membership,
                        publication: publication,
                        non_duplicate_publication_group_id: non_duplicate_group_id
    end

    def create_activity_insight_publication_import(publication)
      FactoryBot.create :publication_import,
                        source: 'Activity Insight',
                        source_identifier: rand(10000000..99999999),
                        publication: publication
    end

    def create_pure_publication_import(publication)
      FactoryBot.create :publication_import,
                        source: 'Pure',
                        source_identifier: FFaker::Lorem.characters(50),
                        publication: publication
    end

    def create_authorship(publication)
      FactoryBot.create :authorship,
                        user: user,
                        publication: publication
    end

    def rand_non_journal_article_type
      Publication.publication_types.map { |type| type if type.exclude?('Journal Article') }.compact.sample
    end

    def rand_journal_article_type
      Publication.publication_types.map { |type| type if /Journal Article/.match?(type) }.compact.sample
    end

    def pub_attrs
      {
        title: FFaker::Lorem.sentence,
        secondary_title: FFaker::Lorem.sentence,
        journal: rand_journal,
        abstract: FFaker::Lorem.paragraph,
        isbn: FFaker::Book.isbn,
        volume: rand(50),
        edition: rand(50),
        doi: "https://doi.org/10.#{rand(1000..9999)}/#{FFaker::Internet.ip_v4_address}",
        published_on: (Date.today - 6.months)
      }
    end

    def rand_journal
      Journal.count.zero? ? FactoryBot.create(:journal) : Journal.find(rand(Journal.count))
    end

    attr_accessor :user
end
