# frozen_string_literal: true

class OpenAccessLocation < ApplicationRecord
  include DeputyUser

  enum :source, to_enum_hash([
                               Source::USER,
                               Source::SCHOLARSPHERE,
                               Source::OPEN_ACCESS_BUTTON,
                               Source::UNPAYWALL,
                               Source::DICKINSON_IDEAS,
                               Source::PSU_LAW_ELIBRARY
                             ]), prefix: :source

  belongs_to :publication, inverse_of: :open_access_locations

  validates :publication, :source, :url, presence: true

  def source
    @source ||= (Source.new(read_attribute(:source)) if read_attribute(:source).present?)
  end

  def name
    "(#{source&.display}) #{url}"
  end

  def options_for_admin_dropdown
    options = if source.present?
                [source]
              else
                [Source::USER, Source::SCHOLARSPHERE]
              end

    options.index_by { |src| Source.new(src.to_s).display }
  end

  def self.create_or_update_from_unpaywall(unpaywall_locations, publication)
    existing_locations = publication.open_access_locations.filter { |l| l.source == Source::UNPAYWALL }

    existing_locations_by_url = existing_locations.index_by(&:url)

    ActiveRecord::Base.transaction do
      unpaywall_locations.each do |unpaywall_location_data|
        unpaywall_url = unpaywall_location_data.url
        open_access_location = existing_locations_by_url.fetch(unpaywall_url) { publication.open_access_locations.build(source: Source::UNPAYWALL, url: unpaywall_url) }

        open_access_location.assign_attributes(
          landing_page_url: unpaywall_location_data.url_for_landing_page,
          pdf_url: unpaywall_location_data.url_for_pdf,
          host_type: unpaywall_location_data.host_type,
          is_best: unpaywall_location_data.is_best,
          license: unpaywall_location_data.license,
          oa_date: unpaywall_location_data.oa_date,
          source_updated_at: unpaywall_location_data.updated,
          version: unpaywall_location_data.version
        )

        open_access_location.save!
      end
    end
  end

  rails_admin do
    show do
      include_all_fields

      field(:source) { pretty_value { Source.new(value).display } }
      field(:oa_date) { label 'OA date' }
      field(:url) do
        label 'URL'
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
      end
      field(:landing_page_url) do
        label 'Landing page URL'
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
      end
      field(:pdf_url) do
        label 'PDF URL'
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
      end
    end

    create do
      field(:url) { label 'URL' }
      field(:source, :enum) do
        enum do
          bindings[:object].options_for_admin_dropdown
        end
      end
    end

    edit do
      field(:url) { label 'URL' }
      field(:source, :enum) do
        enum do
          bindings[:object].options_for_admin_dropdown
        end
      end
    end
  end
end
