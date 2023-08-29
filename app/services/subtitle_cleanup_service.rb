# frozen_string_literal: true

class SubtitleCleanupService
  def self.call
    Publication.find_each do |publication|
      if publication.secondary_title.present?
        publication.update(secondary_title: nil) if publication.title.include?(publication.secondary_title)
      end
    end
  end
end
