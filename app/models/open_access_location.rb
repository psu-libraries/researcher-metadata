# frozen_string_literal: true

class OpenAccessLocation < ApplicationRecord
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
    "#{url} (#{source&.display})"
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
          if value
            [value].index_by { |str| Source.new(str).display }
          else
            [Source::USER, Source::SCHOLARSPHERE].index_by { |str| Source.new(str).display }
          end
        end
      end
    end

    edit do
      field(:url) { label 'URL' }
      field(:source, :enum) do
        enum do
          if value
            [value].index_by { |str| Source.new(str).display }
          else
            [Source::USER, Source::SCHOLARSPHERE].index_by { |str| Source.new(str).display }
          end
        end
      end
    end
  end
end
