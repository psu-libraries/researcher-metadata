class AuthorshipMergePolicy
  def initialize(authorships)
    @authorships = authorships
  end

  def orcid_resource_id_to_keep
    authorships.select { |a| a.orcid_resource_identifier.present? }
      .sort { |a, b| a.updated_by_owner <=> b.updated_by_owner }
      .last.try(:orcid_resource_identifier)
  end

  def confirmed_value_to_keep
    !!authorships.detect { |a| a.confirmed.present? }
  end

  def role_to_keep
    authorships.detect { |a| a.role.present? }.try(:role)
  end

  def oa_timestamp_to_keep
    authorships.select { |a| a.open_access_notification_sent_at.present? }
      .sort { |a, b| a.open_access_notification_sent_at <=> b.open_access_notification_sent_at }
      .last.try(:open_access_notification_sent_at)
  end

  def owner_update_timestamp_to_keep
    authorships.select { |a| a.updated_by_owner_at.present? }
      .sort { |a, b| a.updated_by_owner_at <=> b.updated_by_owner_at }
      .last.try(:updated_by_owner_at)
  end

  private

  attr_reader :authorships
end
