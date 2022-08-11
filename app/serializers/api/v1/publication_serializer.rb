# frozen_string_literal: true

module API::V1
  class PublicationSerializer
    include JSONAPI::Serializer
    attributes :title, :secondary_title, :publication_type, :status, :volume, :issue,
               :edition, :page_range, :authors_et_al, :abstract, :doi, :preferred_open_access_url

    attribute :publisher, &:preferred_publisher_name

    attribute :journal_title, &:preferred_journal_title

    attribute :published_on do |object|
      object.published_on.try(:iso8601)
    end

    attribute :citation_count, &:total_scopus_citations

    attribute :contributors do |object|
      object.contributor_names.map do |c|
        { first_name: c.first_name,
          middle_name: c.middle_name,
          last_name: c.last_name,
          psu_user_id: c.webaccess_id }
      end
    end

    attribute :tags do |object|
      object.taggings.order(rank: :desc).map do |t|
        { name: t.name,
          rank: t.rank }
      end
    end

    attribute :pure_ids, &:pure_import_identifiers

    attribute :activity_insight_ids, &:ai_import_identifiers

    attribute :profile_preferences do |object|
      object.confirmed_authorships.map do |a|
        { user_id: a.user_id,
          webaccess_id: a.user_webaccess_id,
          visible_in_profile: a.visible_in_profile,
          position_in_profile: a.position_in_profile }
      end
    end
  end
end
