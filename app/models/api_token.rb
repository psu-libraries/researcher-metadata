# frozen_string_literal: true

class APIToken < ApplicationRecord
  before_create :set_token

  has_many :organization_api_permissions, inverse_of: :api_token
  has_many :organizations, through: :organization_api_permissions
  has_many :users, through: :organizations
  has_many :publications, through: :users

  def all_publications
    Publication.joins(users: :organizations)
      .where(organizations: { id: descendant_org_ids })
      .published_during_membership
      .distinct(:id)
  end

  def all_current_users
    User.joins(:user_organization_memberships)
      .where(user_organization_memberships: { organization_id: descendant_org_ids })
      .where('user_organization_memberships.ended_on IS NULL OR user_organization_memberships.ended_on > ?', DateTime.now)
      .distinct(:id)
  end

  def all_organizations
    Organization.where(id: descendant_org_ids).distinct(:id)
  end

  def increment_request_count
    update_column(:total_requests, total_requests + 1)
    update_column(:last_used_at, Time.current)
  end

  def organization_count
    organizations.count
  end

  rails_admin do
    show do
      field(:token)
      field(:app_name)
      field(:admin_email)
      field(:write_access)
      field(:total_requests)
      field(:last_used_at)
      field(:organizations)
    end

    list do
      field(:id)
      field(:token)
      field(:app_name)
      field(:organization_count) { label 'Orgs' }
      field(:total_requests)
      field(:last_used_at)
      field(:admin_email)
      field(:write_access)
      field(:created_at)
      field(:updated_at)
    end

    create do
      field(:admin_email)
      field(:app_name)
      field(:write_access)
      field(:organizations)
    end

    edit do
      field(:admin_email)
      field(:app_name)
      field(:write_access)
      field(:organizations)
    end
  end

  private

    def descendant_org_ids
      organizations.map(&:descendant_ids).flatten
    end

    def set_token
      self.token ||= SecureRandom.hex(48)
    end
end
