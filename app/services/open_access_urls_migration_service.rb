# frozen_string_literal: true

class OpenAccessUrlsMigrationService
  def self.call
    Publication.find_each do |pub|
      if oa_url = pub.read_attribute(:open_access_url).presence
        OpenAccessLocation.find_or_create_by(source: Source::OPEN_ACCESS_BUTTON,
                                             url: oa_url,
                                             publication_id: pub.id)
      end
      if ss_url = pub.read_attribute(:scholarsphere_open_access_url).presence
        OpenAccessLocation.find_or_create_by(source: Source::SCHOLARSPHERE,
                                             url: ss_url,
                                             publication_id: pub.id)
      end
      if usr_url = pub.read_attribute(:user_submitted_open_access_url).presence
        OpenAccessLocation.find_or_create_by(source: Source::USER,
                                             url: usr_url,
                                             publication_id: pub.id)
      end
    end
  end
end
