class User < ApplicationRecord
  include Swagger::Blocks

  before_validation :downcase_webaccess_id,
                    :convert_blank_psu_id_to_nil,
                    :convert_blank_pure_id_to_nil,
                    :convert_blank_ai_id_to_nil

  Devise.add_module(:http_header_authenticatable,
                    strategy: true,
                    controller: 'user/sessions',
                    model: 'devise/models/http_header_authenticatable')

  devise :http_header_authenticatable

  validates :webaccess_id, presence: true, uniqueness: { case_sensitive: false }
  validates :activity_insight_identifier,
            :pure_uuid,
            :penn_state_identifier,
            uniqueness: { allow_nil: true }
  validates :first_name, :last_name, presence: true

  has_many :authorships
  has_many :publications, through: :authorships
  has_many :user_contracts
  has_many :contracts, through: :user_contracts
  has_many :committee_memberships, inverse_of: :user
  has_many :etds, through: :committee_memberships
  has_many :user_performances
  has_many :performances, through: :user_performances
  has_many :presentation_contributions
  has_many :presentations, through: :presentation_contributions
  has_many :news_feed_items
  has_many :user_organization_memberships, inverse_of: :user
  has_many :organizations, through: :user_organization_memberships
  has_many :managed_organizations, class_name: :Organization, foreign_key: :owner_id
  has_many :managed_users, through: :managed_organizations, source: :users
  has_many :education_history_items
  has_many :researcher_funds, inverse_of: :user
  has_many :grants, through: :researcher_funds
  has_many :external_publication_waivers

  accepts_nested_attributes_for :user_organization_memberships, allow_destroy: true

  def self.find_all_by_wos_pub(pub)
    users = []
    users += find_confirmed_by_wos_pub(pub)
    pub.author_names.each do |an|
      if an.first_name && an.middle_name
        users += where(first_name: an.first_name, middle_name: an.middle_name, last_name: an.last_name).
          or(where(first_name: an.first_name, last_name: an.last_name))
      end
      if an.first_name && an.middle_initial
        users += where("first_name = ? AND middle_name ILIKE ? AND last_name = ?",
                      an.first_name,
                      "#{an.middle_initial}%",
                      an.last_name).
          or(where(first_name: an.first_name, last_name: an.last_name))
      end
      if an.first_name && !(an.middle_name || an.middle_initial)
        users += where(first_name: an.first_name, last_name: an.last_name)
      end
      if an.first_initial && an.middle_initial
        users += where("first_name ILIKE ? AND middle_name ILIKE ? AND last_name =?",
                       "#{an.first_initial}%",
                       "#{an.middle_initial}%",
                       an.last_name)
      end
    end
    users.uniq
  end

  def self.find_confirmed_by_wos_pub(pub)
    where(orcid_identifier: pub.orcids.map { |o| "https://orcid.org/#{o}" })
  end

  def self.find_by_nsf_grant(grant)
    users = []
    grant.investigators.each do |i|
      if i.psu_email_name
        user_by_email = find_by(webaccess_id: i.psu_email_name)
        users << user_by_email if user_by_email
      end
      if i.first_name && i.last_name
        user_by_name = find_by(first_name: i.first_name, last_name: i.last_name)
        users << user_by_name if user_by_name
      end
    end
    users.uniq
  end

  def self.needs_open_access_notification
    joins({authorships: :publication}, :user_organization_memberships).
    where('users.open_access_notification_sent_at IS NULL OR users.open_access_notification_sent_at < ?', 6.months.ago).
    where('publications.published_on >= ?', Publication::OPEN_ACCESS_POLICY_START).
    where('publications.published_on >= user_organization_memberships.started_on AND (publications.published_on <= user_organization_memberships.ended_on OR user_organization_memberships.ended_on IS NULL)').
    where('authorships.confirmed IS TRUE').
    select { |u| u.publications.subject_to_open_access_policy.detect { |p| p.authorships.detect { |a| a.no_open_access_information? } } }.uniq
  end

  def potential_open_access_publications
    publications.
      joins(:authorships).
      published_during_membership.
      subject_to_open_access_policy.
      where('authorships.confirmed IS TRUE').
      select { |p| p.authorships.detect { |a| a.no_open_access_information? } }
  end

  def confirmed_publications
    publications.where(authorships: { confirmed: true })
  end

  def admin?
    is_admin
  end

  def name
    full_name = first_name.to_s
    full_name += ' ' if first_name.present? && middle_name.present?
    full_name += middle_name.to_s if middle_name.present?
    full_name += ' ' if middle_name.present? && last_name.present? || first_name.present? && last_name.present?
    full_name += last_name.to_s if last_name.present?
    full_name
  end

  def total_scopus_citations
    publications.sum(:total_scopus_citations)
  end

  def pure_profile_url
    "https://pennstate.pure.elsevier.com/en/persons/#{pure_uuid}" if pure_uuid.present?
  end

  def office_phone_number
    if ai_office_area_code.present? && ai_office_phone_1.present? && ai_office_phone_2.present?
      "(#{ai_office_area_code}) #{ai_office_phone_1}-#{ai_office_phone_2}"
    end
  end

  def fax_number
    if ai_fax_area_code.present? && ai_fax_1.present? && ai_fax_2.present?
      "(#{ai_fax_area_code}) #{ai_fax_1}-#{ai_fax_2}"
    end
  end

  def office_location
    if ai_room_number.present? && ai_building.present?
      "#{ai_room_number} #{ai_building.titleize}"
    end
  end

  def organization_name
    primary_organization_membership.try(:organization_name)
  end

  def primary_organization_membership
    user_organization_memberships.where.not(pure_identifier: nil).first
  end

  def orcid
    orcid_identifier.gsub("https://orcid.org/", "").presence if orcid_identifier
  end

  def clear_orcid_access_token
    update_attribute(:orcid_access_token, nil)
  end

  def record_open_access_notification
    update_attribute(:open_access_notification_sent_at, Time.current)
  end

  rails_admin do
    configure :publications do
      pretty_value do
        bindings[:view].render :partial => "rails_admin/partials/users/publications.html.erb", :locals => { :publications => value }
      end
    end

    list do
      field(:id) do
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
      field(:webaccess_id) { label 'Penn State WebAccess ID' }
      field(:first_name)
      field(:middle_name)
      field(:last_name)
      field(:penn_state_identifier) do
        label 'Penn State ID'
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
      field(:pure_uuid) do
        label 'Pure ID'
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
      field(:activity_insight_identifier) do
        label 'Activity Insight ID'
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
      field(:orcid_identifier) do
        label 'ORCID'
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
      end
      field(:is_admin) do
        label 'Admin user?'
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
      field(:show_all_publications, :toggle)
      field(:show_all_contracts, :toggle)
      field(:scopus_h_index) do
        label 'H-Index'
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
      field(:created_at) do
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
      field(:updated_at) do
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
      field(:updated_by_user_at) do
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
    end

    show do
      field(:webaccess_id) { label 'Penn State WebAccess ID' }
      field(:pure_uuid) { label 'Pure ID' }
      field(:activity_insight_identifier) { label 'Activity Insight ID' }
      field(:penn_state_identifier) { label 'Penn State ID' }
      field(:scopus_h_index) { label 'H-Index' }
      field(:ai_title) { label 'Title' }
      field(:ai_rank) { label 'Rank' }
      field(:ai_endowed_title) { label 'Endowed Title' }
      field(:orcid_identifier) do
        label 'ORCID ID'
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
      end
      field(:ai_alt_name) { label 'Alternate Name' }
      field(:ai_building) { label 'Building' }
      field(:ai_room_number) { label 'Room Number' }
      field(:office_phone_number) { label 'Office Phone Number' }
      field(:fax_number) { label 'Fax Number' }
      field(:ai_website) { label 'Personal Website' }
      field(:ai_google_scholar) { label 'Google Scholar URL' }
      field(:ai_bio) { label 'Bio' }
      field(:ai_teaching_interests) { label 'Teaching Interests' }
      field(:ai_research_interests) { label 'Research Interests' }
      field(:education_history_items)
      field(:is_admin) { label 'Admin user?' }
      field(:show_all_publications)
      field(:show_all_contracts)
      field(:managed_organizations)
      field(:created_at)
      field(:updated_at)
      field(:updated_by_user_at)

      field(:publications)
      field(:presentations)
      field(:contracts)
      field(:grants)
      field(:etds)
      field(:news_feed_items)
      field(:user_organization_memberships)
      field(:organizations)
      field(:performances)
    end

    create do
      field(:webaccess_id) { label 'Penn State WebAccess ID' }
      field(:first_name)
      field(:middle_name)
      field(:last_name)
      field(:pure_uuid) { label 'Pure ID' }
      field(:activity_insight_identifier) { label 'Activity Insight ID' }
      field(:penn_state_identifier) { label 'Penn State ID' }
      field(:is_admin) { label 'Admin user?' }
      field(:show_all_publications)
      field(:show_all_contracts)
      field(:created_at) { read_only true }
      field(:updated_at) { read_only true }
      field(:updated_by_user_at) { read_only true }
    end

    edit do
      field(:webaccess_id) do
        read_only true
        label 'Penn State WebAccess ID'
      end
      field(:first_name) do
        read_only do
          !bindings[:view]._current_user.is_admin
        end
      end
      field(:middle_name) do
        read_only do
          !bindings[:view]._current_user.is_admin
        end
      end
      field(:last_name) do
        read_only do
          !bindings[:view]._current_user.is_admin
        end
      end
      field(:pure_uuid) do
        label 'Pure ID'
        read_only do
          !bindings[:view]._current_user.is_admin
        end
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
      field(:activity_insight_identifier) do
        label 'Activity Insight ID'
        read_only do
          !bindings[:view]._current_user.is_admin
        end
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
      field(:penn_state_identifier) do
        label 'Penn State ID'
        read_only do
          !bindings[:view]._current_user.is_admin
        end
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
      field(:is_admin) do
        label 'Admin user?'
        read_only do
          !bindings[:view]._current_user.is_admin
        end
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
      field(:show_all_publications)
      field(:show_all_contracts)
      field(:managed_organizations) do
        read_only do
          !bindings[:view]._current_user.is_admin
        end
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
      field(:user_organization_memberships) do
        read_only do
          !bindings[:view]._current_user.is_admin
        end
      end
      field(:created_at) do
        read_only true
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
      field(:updated_at) do
        read_only true
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
      field(:updated_by_user_at) do
        read_only true
        visible do
          bindings[:view]._current_user.is_admin
        end
      end
    end
  end

  def mark_as_updated_by_user
    self.updated_by_user_at = Time.current
  end

  private

  def downcase_webaccess_id
    self.webaccess_id = self.webaccess_id.downcase if self.webaccess_id.present?
  end

  def convert_blank_psu_id_to_nil
    self.penn_state_identifier = nil if self.penn_state_identifier.blank?
  end

  def convert_blank_pure_id_to_nil
    self.pure_uuid = nil if self.pure_uuid.blank?
  end

  def convert_blank_ai_id_to_nil
    self.activity_insight_identifier = nil if self.activity_insight_identifier.blank?
  end
end
