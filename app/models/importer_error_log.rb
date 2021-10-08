# frozen_string_literal: true

class ImporterErrorLog < ApplicationRecord
  self.inheritance_column = 'importer_type'

  validates :error_type,
            :stacktrace,
            :occurred_at,
            presence: true
end
