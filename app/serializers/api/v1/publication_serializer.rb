module API::V1
  class PublicationSerializer
    include FastJsonapi::ObjectSerializer
    attributes :title, :secondary_title, :publication_type, :status, :volume, :issue,
               :edition, :page_range, :authors_et_al, :abstract, :doi, :preferred_open_access_url

    attribute :publisher do |object|
      object.preferred_publisher_name
    end

    attribute :journal_title do |object|
      object.preferred_journal_title
    end

    attribute :published_on do |object|
      object.published_on.try(:iso8601)
    end

    attribute :citation_count do |object|
      object.total_scopus_citations
    end

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

    attribute :pure_ids do |object|
      object.pure_import_identifiers
    end

    attribute :activity_insight_ids do |object|
      object.ai_import_identifiers
    end

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
