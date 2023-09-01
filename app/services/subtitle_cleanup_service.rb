# frozen_string_literal: true

class SubtitleCleanupService
  def self.call
    Publication.find_each do |publication|
      if publication.secondary_title.present? && publication.title.include?(publication.secondary_title)
        publication.update(secondary_title: nil)
      end
    end
  end
end
