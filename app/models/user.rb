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
  has_many :presentation_contributions
  has_many :presentations, through: :presentation_contributions
  has_many :news_feed_items
  has_many :user_organization_memberships, inverse_of: :user
  has_many :organizations, through: :user_organization_memberships

  accepts_nested_attributes_for :user_organization_memberships, allow_destroy: true

  swagger_schema :User do
    property :webaccess_id do
      key :type, :string
    end
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

  rails_admin do
    configure :publications do
      pretty_value do
        bindings[:view].render :partial => "rails_admin/partials/users/publications.html.erb", :locals => { :publications => value }
      end
    end

    list do
      field(:id)
      field(:webaccess_id) { label 'Penn State WebAccess ID' }
      field(:first_name)
      field(:middle_name)
      field(:last_name)
      field(:penn_state_identifier) { label 'Penn State ID' }
      field(:pure_uuid) { label 'Pure ID' }
      field(:activity_insight_identifier) { label 'Activity Insight ID' }
      field(:is_admin) { label 'Admin user?' }
      field(:created_at)
      field(:updated_at)
      field(:updated_by_user_at)
    end

    show do
      field(:webaccess_id) { label 'Penn State WebAccess ID' }
      field(:pure_uuid) { label 'Pure ID' }
      field(:activity_insight_identifier) { label 'Activity Insight ID' }
      field(:penn_state_identifier) { label 'Penn State ID' }
      field(:is_admin) { label 'Admin user?' }
      field(:created_at)
      field(:updated_at)
      field(:updated_by_user_at)

      field(:publications)
      field(:presentations)
      field(:user_organization_memberships)
      field(:organizations)
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
      field(:created_at) { read_only true }
      field(:updated_at) { read_only true }
      field(:updated_by_user_at) { read_only true }
    end

    edit do
      field(:webaccess_id) do
        read_only true
        label 'Penn State WebAccess ID'
      end
      field(:first_name)
      field(:middle_name)
      field(:last_name)
      field(:pure_uuid) { label 'Pure ID' }
      field(:activity_insight_identifier) { label 'Activity Insight ID' }
      field(:penn_state_identifier) { label 'Penn State ID' }
      field(:is_admin) { label 'Admin user?' }
      field(:user_organization_memberships)

      field(:created_at) { read_only true }
      field(:updated_at) { read_only true }
      field(:updated_by_user_at) { read_only true }
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
