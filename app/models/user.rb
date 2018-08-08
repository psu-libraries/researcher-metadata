class User < ApplicationRecord
  include Swagger::Blocks

  before_validation :downcase_webaccess_id

  Devise.add_module(:http_header_authenticatable,
                    strategy: true,
                    controller: 'user/sessions',
                    model: 'devise/models/http_header_authenticatable')

  devise :http_header_authenticatable

  validates :webaccess_id, presence: true, uniqueness: { case_sensitive: false }
  validates :activity_insight_identifier, :pure_uuid, uniqueness: { allow_nil: true }
  validates :first_name, :last_name, presence: true

  has_many :authorships
  has_many :publications, through: :authorships

  swagger_schema :User do
    property :webaccess_id do
      key :type, :string
    end
  end

  def admin?
    is_admin
  end

 def name
    if middle_name.present?
      first_name + ' ' + middle_name + ' ' + last_name
    else
      first_name + ' ' + last_name
    end
  end

  rails_admin do
    configure :publications do
      pretty_value do
        bindings[:view].render :partial => "rails_admin/partials/users/publications.html.erb", :locals => { :publications => value }
      end
    end

    show do
      field :webaccess_id
      field :pure_uuid
      field :activity_insight_identifier
      field :penn_state_identifier
      field :title
      field :is_admin
      field :created_at
      field :updated_at

      field :publications
    end
  end

  private

  def downcase_webaccess_id
    self.webaccess_id = self.webaccess_id.downcase if self.webaccess_id.present?
  end
end
