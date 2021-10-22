# frozen_string_literal: true

class OpenAccessUrlsMigrationService
  def self.call
    Publication.find_each do |pub|
      if pub.open_access_url
        OpenAccessLocation.find_or_create_by(source: Source::OPEN_ACCESS_BUTTON,
                                             url: pub.open_access_url,
                                             publication_id: pub.id)
      end
      if pub.scholarsphere_open_access_url
        OpenAccessLocation.find_or_create_by(source: Source::SCHOLARSPHERE,
                                             url: pub.scholarsphere_open_access_url,
                                             publication_id: pub.id)
      end
      if pub.user_submitted_open_access_url
        OpenAccessLocation.find_or_create_by(source: Source::USER,
                                             url: pub.user_submitted_open_access_url,
                                             publication_id: pub.id)
      end
    end
  end
end
