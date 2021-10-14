# frozen_string_literal: true

class User < ApplicationRecord
  class OmniauthError < RuntimeError; end

  include Swagger::Blocks
  include Admin::Users

  before_validation :downcase_webaccess_id,
                    :convert_blank_psu_id_to_nil,
                    :convert_blank_pure_id_to_nil,
                    :convert_blank_ai_id_to_nil

  devise :omniauthable, omniauth_providers: %i[azure_oauth]

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
  has_many :contributor_names

  accepts_nested_attributes_for :user_organization_memberships, allow_destroy: true

  def self.from_omniauth(auth)
    # We've added `uid` and `provider` fields to this model to support
    # multi-provider omniauth, but in reality, we're only using one provider
    # (Azure Active Directory), and we already have all of our users and their IDs
    # (stored in the existing `webaccess_id` field). Additionally, at least for now,
    # we're not provisioning new users from Azure AD. So we don't really have a need
    # to use these new fields or to rearrange our user model to allow for other
    # authentication providers or for provisioning.
    User.find_by!(webaccess_id: auth.uid)
  rescue ActiveRecord::RecordNotFound
    raise OmniauthError
  end

  def self.find_all_by_wos_pub(pub)
    users = []
    users += find_confirmed_by_wos_pub(pub)
    pub.author_names.each do |an|
      if an.first_name && an.middle_name
        users += where(first_name: an.first_name, middle_name: an.middle_name, last_name: an.last_name)
          .or(where(first_name: an.first_name, last_name: an.last_name))
      end
      if an.first_name && an.middle_initial
        users += where('first_name = ? AND middle_name ILIKE ? AND last_name = ?',
                       an.first_name,
                       "#{an.middle_initial}%",
                       an.last_name)
          .or(where(first_name: an.first_name, last_name: an.last_name))
      end
      if an.first_name && !(an.middle_name || an.middle_initial)
        users += where(first_name: an.first_name, last_name: an.last_name)
      end
      if an.first_initial && an.middle_initial
        users += where('first_name ILIKE ? AND middle_name ILIKE ? AND last_name =?',
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
    joins(:authorships, :publications, :user_organization_memberships)
      .where(publications: { status: Publication::PUBLISHED_STATUS })
      .where("publications.publication_type ~* 'Journal Article'")
      .where('publications.id NOT IN (SELECT publication_id from authorships WHERE authorships.id IN (SELECT authorship_id FROM internal_publication_waivers))')
      .where(%{publications.id NOT IN (SELECT publication_id from authorships WHERE authorships.id IN (SELECT authorship_id FROM scholarsphere_work_deposits WHERE status = 'Pending'))})
      .where('users.open_access_notification_sent_at IS NULL OR users.open_access_notification_sent_at < ?', 6.months.ago)
      .where('publications.published_on >= ?', Publication::OPEN_ACCESS_POLICY_START)
      .where('publications.published_on >= user_organization_memberships.started_on AND (publications.published_on <= user_organization_memberships.ended_on OR user_organization_memberships.ended_on IS NULL)')
      .where('authorships.confirmed IS TRUE')
      .where("(publications.open_access_url IS NULL OR publications.open_access_url = '') AND (publications.user_submitted_open_access_url IS NULL OR publications.user_submitted_open_access_url = '') AND (publications.scholarsphere_open_access_url IS NULL OR publications.scholarsphere_open_access_url = '')")
      .where('publications.visible = true')
      .distinct(:id)
  end

  def psu_identity
    return if attributes['psu_identity'].blank?

    PsuIdentity::SearchService::Person.new(attributes['psu_identity']['data'])
  end

  def update_psu_identity
    update(psu_identity: psu_identity_data, psu_identity_updated_at: Time.zone.now)
  end

  def old_potential_open_access_publications
    potential_open_access_publications
      .where.not('authorships.open_access_notification_sent_at' => nil)
      .select(&:no_open_access_information?)
  end

  def new_potential_open_access_publications
    potential_open_access_publications
      .where(authorships: { open_access_notification_sent_at: nil })
      .select(&:no_open_access_information?)
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
    user_organization_memberships.where(import_source: 'Pure').first
  end

  def orcid
    orcid_identifier.gsub('https://orcid.org/', '').presence if orcid_identifier
  end

  def clear_orcid_access_token
    update_attribute(:orcid_access_token, nil)
  end

  def record_open_access_notification
    update_attribute(:open_access_notification_sent_at, Time.current)
  end

  def mark_as_updated_by_user
    self.updated_by_user_at = Time.current
  end

  private

    def downcase_webaccess_id
      self.webaccess_id = webaccess_id.downcase if webaccess_id.present?
    end

    def convert_blank_psu_id_to_nil
      self.penn_state_identifier = nil if penn_state_identifier.blank?
    end

    def convert_blank_pure_id_to_nil
      self.pure_uuid = nil if pure_uuid.blank?
    end

    def convert_blank_ai_id_to_nil
      self.activity_insight_identifier = nil if activity_insight_identifier.blank?
    end

    def potential_open_access_publications
      publications
        .joins(:authorships)
        .published_during_membership
        .subject_to_open_access_policy
        .where('authorships.confirmed IS TRUE')
    end

    def psu_identity_data
      @psu_identity_data ||= PsuIdentity::SearchService::Client.new.userid(webaccess_id)
    end
end
