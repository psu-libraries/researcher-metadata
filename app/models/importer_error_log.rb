# frozen_string_literal: true

class ImporterErrorLog < ApplicationRecord
  self.inheritance_column = 'importer_type'

  validates :error_type,
            :stacktrace,
            :occurred_at,
            presence: true

  def self.log_error(error:, metadata:)
    create!(
      error_type: error.class.to_s,
      error_message: error.message.to_s,
      metadata: metadata,
      occurred_at: Time.zone.now,
      stacktrace: error.backtrace.to_s
    )
  end
end
