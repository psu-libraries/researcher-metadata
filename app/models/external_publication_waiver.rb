class ExternalPublicationWaiver < ApplicationRecord
  belongs_to :user, inverse_of: :external_publication_waivers

  validates :user, :publication_title, :journal_title, :doi, presence: true

  def title
    publication_title
  end

  rails_admin do
    list do
      field(:id)
      field(:publication_title)
      field(:user) do
        pretty_value { value.name }
      end
    end

    show do
      field(:id)
      field(:publication_title)
      field(:reason_for_waiver)
      field(:abstract)
      field(:doi)
      field(:journal_title)
      field(:publisher)
      field(:user) do
        pretty_value { %{<a href="#{RailsAdmin.railtie_routes_url_helpers.show_path(model_name: :user, id: value.id)}">#{value.name}</a>}.html_safe }
      end
    end
  end
end
