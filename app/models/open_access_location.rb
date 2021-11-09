# frozen_string_literal: true

class OpenAccessLocation < ApplicationRecord
  include DeputyUser

  enum source: to_enum_hash([
                              Source::USER,
                              Source::SCHOLARSPHERE,
                              Source::OPEN_ACCESS_BUTTON,
                              Source::UNPAYWALL,
                              Source::DICKINSON_IDEAS,
                              Source::PSU_LAW_ELIBRARY
                            ]),
       _prefix: :source

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
