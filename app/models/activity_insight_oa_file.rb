# frozen_string_literal: true

class ActivityInsightOAFile < ApplicationRecord
  belongs_to :publication,
             inverse_of: :activity_insight_oa_files

  ALLOWED_VERSIONS = [I18n.t('file_versions.accepted_version'),
                      I18n.t('file_versions.published_version'),
                      'unknown']

  def version_status_display
    return 'Unknown Version' if version == 'unknown'

    'Wrong Version'
  end

  rails_admin do
    show do
      field(:location)
      field(:version)
      field(:created_at)
      field(:updated_at)
      field(:publication)
    end

    list do
      field(:id)
      field(:location)
      field(:version)
      field(:created_at)
      field(:updated_at)
      field(:publication)
    end

    edit do
      field(:location) { read_only true }
      field(:version, :enum) do
        enum do
          ActivityInsightOAFile::ALLOWED_VERSIONS.map { |v| [v, v] }
        end
      end
    end
  end
end
