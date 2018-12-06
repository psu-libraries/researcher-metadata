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

  accepts_nested_attributes_for :user_organization_memberships, allow_destroy: true

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
      field(:etds)
      field(:news_feed_items)
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
