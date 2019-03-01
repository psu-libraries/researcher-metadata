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

  def publications
    user_query.publications({order_first_by: 'publication_date_desc'}).map do |pub|
      p = pub.title
      p += ", #{pub.journal_title || pub.publisher}" if pub.journal_title.present? || pub.publisher.present?
      p += ", #{pub.published_on.year}" if pub.published_on.present?
      p
    end
  end

  def grants
    []
  end

  def presentations
    []
  end

  def performances
    []
  end

  def advising_roles
    []
  end

  def news_stories
    []
  end

  private

  attr_reader :user

  def user_query
    API::V1::UserQuery.new(user)
  end
end