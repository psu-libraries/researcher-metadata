# frozen_string_literal: true

module PublicationCleanupService
  def self.clean_up_pure_publications(dry_run: true)
    Publication.with_only_pure_imports.find_each do |pub|
      if !SourcePublication.find_in_latest_pure_list(pub) && PurePersonFinder.new.detect_publication_author(pub)
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
