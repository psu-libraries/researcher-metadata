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

  def waiver_to_keep
    authorships.select { |a| a.waiver.present? }
      .sort { |a, b| a.updated_by_owner <=> b.updated_by_owner }
      .last.try(:waiver)
  end

  def waivers_to_destroy
    all_waivers = authorships.map { |a| a.waiver }
    wtd = all_waivers - [waiver_to_keep]
    wtd.compact
  end

  def visibility_value_to_keep
    authorships.sort { |a, b| a.updated_by_owner <=> b.updated_by_owner }
      .last.visible_in_profile
  end

  def position_value_to_keep
    authorships.select { |a| a.position_in_profile.present? }
      .sort { |a, b| a.updated_by_owner <=> b.updated_by_owner }
      .last.try(:position_in_profile)
  end

  def scholarsphere_timestamp_to_keep
    authorships.select { |a| a.scholarsphere_uploaded_at.present? }
      .sort { |a, b| a.scholarsphere_uploaded_at <=> b.scholarsphere_uploaded_at }
      .last.try(:scholarsphere_uploaded_at)
  end

  private

  attr_reader :authorships
end
