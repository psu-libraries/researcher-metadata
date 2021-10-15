# frozen_string_literal: true

class OpenAccessLocation < ApplicationRecord
  def self.sources
    [
      'User',
      'ScholarSphere',
      'Open Access Button',
      'Unpaywall',
      'Dickinson Law IDEAS Repo',
      'Penn State Law eLibrary Repo'
    ]
  end

  belongs_to :publication, inverse_of: :open_access_locations

  validates :publication, :source, :url, presence: true
  validates :source, inclusion: { in: sources }

  rails_admin do
    show do
      include_all_fields

      field(:url) do
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
      end
      field(:landing_page_url) do
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
      end
      field(:pdf_url) do
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
      end
    end
  end
end
