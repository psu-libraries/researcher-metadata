# frozen_string_literal: true

class ImporterErrorLog < ApplicationRecord
  validates :importer_type,
            :error_type,
            :stacktrace,
            :occurred_at,
            presence: true

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
end
