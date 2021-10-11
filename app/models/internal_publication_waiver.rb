# frozen_string_literal: true

class InternalPublicationWaiver < ApplicationRecord
  belongs_to :authorship, inverse_of: :waiver
  has_one :user, through: :authorship
  has_one :publication, through: :authorship
  has_one :external_publication_waiver, inverse_of: :internal_publication_waiver

  delegate :abstract, :doi, :published_by, to: :authorship, prefix: false
  delegate :title, to: :authorship, allow_nil: true

  alias_method :publication_title, :title
  alias_method :journal_title, :published_by

  def publisher
    nil
  end

  rails_admin do
    list do
      field(:id)
      field(:publication) do
        pretty_value { value.title }
      end
      field(:user) do
        pretty_value { value.name }
      end
      field(:created_at)
    end

    show do
      field(:id)
      field(:publication) do
        pretty_value { %{<a href="#{RailsAdmin.railtie_routes_url_helpers.show_path(model_name: :publication, id: value.id)}">#{value.title}</a>}.html_safe }
      end
      field(:user) do
        pretty_value { %{<a href="#{RailsAdmin.railtie_routes_url_helpers.show_path(model_name: :user, id: value.id)}">#{value.name}</a>}.html_safe }
      end
      field(:reason_for_waiver)
      field(:authorship)
      field(:external_publication_waiver)
      field(:created_at)
      field(:updated_at)
    end

    create do
      field(:authorship)
      field(:reason_for_waiver)
    end

    edit do
      field(:authorship) { read_only true }
      field(:reason_for_waiver)
      field(:user)
      field(:publication)
    end
  end
end
