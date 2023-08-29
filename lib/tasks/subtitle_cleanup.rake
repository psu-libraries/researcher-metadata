# frozen_string_literal: true

desc 'Runs SubtitleCleanupService to remove secondary_titles
      if they are included in the title'
task subtitle_cleanup: :environment do
  SubtitleCleanupService.call
end
