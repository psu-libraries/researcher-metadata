class Person < ApplicationRecord
  has_one :user
  has_many :authorships
  has_many :publications, through: :authorships
  validates :first_name, :last_name, presence: true

  def name
    full_name = first_name
    full_name = full_name + ' ' + middle_name if middle_name
    full_name = full_name + ' ' + last_name if last_name
    full_name
  end

  rails_admin do
    configure :publications do
      pretty_value do
        bindings[:view].render :partial => "rails_admin/partials/users/publications.html.erb", :locals => { :publications => value }
      end
    end

    show do
      field :publications
    end
  end
end
