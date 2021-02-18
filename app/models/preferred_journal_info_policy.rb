class PreferredJournalInfoPolicy
  def initialize(publication)
    @publication = publication
  end

  def journal_title
    publication.journal.try(:title).presence || publication.journal_title.presence
  end

  def publisher_name
    publication.publisher.try(:name).presence || publication.publisher_name.presence
  end

  private

  attr_reader :publication
end
