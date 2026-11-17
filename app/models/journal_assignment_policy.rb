# frozen_string_literal: true

class JournalAssignmentPolicy
  def self.allow?(publication:, target_journal:, persisted: false)
    current_journal = publication.journal

    # New publications can join any journal
    return true unless publication.persisted?

    # No reassignment necessary because they are the same
    return true if current_journal == target_journal

    # Existing publications cannot move into or out
    # of an admin-edited journal
    return false if current_journal&.edited_manually?
    return false if target_journal&.edited_manually?

    # Normal assignments of persisted pubs not assigned to
    # or being assigned to edited journals
    true
  end
end
