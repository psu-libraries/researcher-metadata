# frozen_string_literal: true

class SourcePublication < ApplicationRecord
  class NoCompletedPureImports < RuntimeError; end
  class NoCompletedAIImports < RuntimeError; end

  belongs_to :import

  def self.find_in_latest_pure_list(publication)
    latest_completed_pure_import = Import.latest_completed_from_pure
    raise NoCompletedPureImports if latest_completed_pure_import.nil?

    publication.pure_imports.each do |i|
      found_pub = find_by(
        import: latest_completed_pure_import,
        source_identifier: i.source_identifier
      )
      return found_pub if found_pub
    end

    nil
  end

  def self.find_in_latest_ai_list(publication)
    latest_completed_ai_import = Import.latest_completed_from_ai
    raise NoCompletedAIImports if latest_completed_ai_import.nil?

    publication.ai_imports.each do |i|
      found_pub = where(
        import: latest_completed_ai_import,
        source_identifier: i.source_identifier
      ).where(%{status = 'Published' OR status = 'In Press'}).first
      return found_pub if found_pub
    end

    nil
  end
end
