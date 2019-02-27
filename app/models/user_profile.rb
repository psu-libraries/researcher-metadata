class UserProfile
  def initialize(user)
    @user = user
  end

  delegate :name,
           :id,
           :office_location,
           :total_scopus_citations,
           :scopus_h_index,
           :pure_profile_url,
           to: :user

  def title
    user.ai_title
  end

  def email
    "#{user.webaccess_id}@psu.edu"
  end

  def personal_website
    user.ai_website
  end

  def bio
    user.ai_bio
  end

  private

  attr_reader :user

  def user_query
    API::V1::UserQuery.new(user)
  end
end