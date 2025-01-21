# frozen_string_literal: true

class ImporterErrorLog < ApplicationRecord
  validates :importer_type,
            :error_type,
            :stacktrace,
            :occurred_at,
            presence: true

  scope :older_than_six_months, -> { where('created_at <= ?', DateTime.now - 6.months) }

  def self.log_error(importer_class:, error:, metadata:)
    create!(
      importer_type: importer_class.to_s,
      error_type: error.class.to_s,
      error_message: error.message.to_s,
      metadata: metadata,
      occurred_at: Time.zone.now,
      stacktrace: error.backtrace.to_s
    )
  end

  rails_admin do
    list do
      field(:importer_type)
      field(:occurred_at)
      field(:error_type)
      field(:error_message)
    end

    show do
      field(:importer_type)
      field(:occurred_at)
      field(:error_type)
      field(:error_message)
      field(:metadata)
      field(:stacktrace, :text) do
        pretty_value do
          pretty_stacktrace = JSON.parse(value)
            .map { |line| line.sub("#{Rails.root}/", '') }
            .join("\n")

          "<pre>#{pretty_stacktrace}</pre>".html_safe
        rescue StandardError
          value
        end
      end
    end
  end
end
