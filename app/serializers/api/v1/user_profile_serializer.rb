# frozen_string_literal: true

module API::V1
  class UserProfileSerializer
    include JSONAPI::Serializer

    attributes :name, :organization_name, :title, :office_location,
               :office_phone_number, :personal_website, :total_scopus_citations,
               :scopus_h_index, :pure_profile_url, :orcid_identifier, :bio,
               :teaching_interests, :research_interests, :publications, :other_publications, :grants,
               :presentations, :performances, :master_advising_roles, :phd_advising_roles,
               :news_stories, :education_history

    attribute :email, if: Proc.new { |record|
      record.active?
    }
  end
end
