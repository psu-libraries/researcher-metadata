class ExternalPublicationWaiver < ApplicationRecord
  belongs_to :user, inverse_of: :external_publication_waivers
  belongs_to :internal_publication_waiver, inverse_of: :external_publication_waiver, optional: true

  validates :user, :publication_title, :journal_title, presence: true

  scope :not_linked, ->{ where(internal_publication_waiver_id: nil) }
  
  def title
    publication_title
  end

  def matching_publications
    Publication.where(%{similarity(CONCAT(title, secondary_title), ?) >= 0.6}, publication_title)
  end

  def has_matching_publications
    matching_publications.any?
  end

  rails_admin do
    configure :matching_publications do
      pretty_value do
        bindings[:view].render :partial => "rails_admin/partials/external_publication_waivers/matching_publications.html.erb", :locals => { :publications => value }
      end
    end
    list do
      scopes [:not_linked]
      field(:id)
      field(:publication_title)
      field(:user) do
        pretty_value { value.name }
      end
      field(:created_at)
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
      field(:internal_publication_waiver)
      field(:matching_publications)
      field(:created_at)
      field(:updated_at)
    end

    create do
      field(:user) do
        inline_add false
        inline_edit false
      end
      field(:publication_title)
      field(:reason_for_waiver)
      field(:abstract)
      field(:doi)
      field(:journal_title)
      field(:publisher)
    end

    edit do
      field(:user) { read_only true }
      field(:publication_title)
      field(:reason_for_waiver)
      field(:abstract)
      field(:doi)
      field(:journal_title)
      field(:publisher)
    end
  end
end
