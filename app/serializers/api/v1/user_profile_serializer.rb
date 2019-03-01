module API::V1
  class UserProfileSerializer
    include FastJsonapi::ObjectSerializer
    attributes :name, :title, :email, :office_location, :personal_website,
               :total_scopus_citations, :scopus_h_index, :pure_profile_url,
               :bio, :publications, :grants, :presentations, :performances,
               :advising_roles, :news_stories
  end
end
