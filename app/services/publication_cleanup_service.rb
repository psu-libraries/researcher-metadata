# frozen_string_literal: true

module PublicationCleanupService
  class IneligiblePublication < RuntimeError; end

  def self.call(dry_run: true)
    Publication.eligible_for_cleanup_check.find_each do |pub|
      raise IneligiblePublication if pub.pure_imports.none? && pub.ai_imports.none?

      if (pub.pure_imports.none? ||
          (!SourcePublication.find_in_latest_pure_list(pub) &&
            PurePersonFinder.new.detect_publication_author(pub))
         ) && (pub.ai_imports.none? || !SourcePublication.find_in_latest_ai_list(pub))
        if dry_run
          puts "Publication #{pub.id} will be deleted"
        else
          puts "Deleting publication #{pub.id}"
          pub.destroy!
        end
      end
    end
  end
end
