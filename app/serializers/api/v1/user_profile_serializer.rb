module API::V1
  class UserProfileSerializer
    include FastJsonapi::ObjectSerializer
    attributes :name, :organization_name, :title, :email, :office_location,
               :office_phone_number, :personal_website, :total_scopus_citations,
               :scopus_h_index, :pure_profile_url, :orcid_identifier, :bio,
               :teaching_interests, :research_interests, :publications, :grants,
               :presentations, :performances, :master_advising_roles, :phd_advising_roles,
               :news_stories, :education_history
  end
end
