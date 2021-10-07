class AuthorshipMergePolicy
  def initialize(authorships)
    @authorships = authorships
  end

  def orcid_resource_id_to_keep
    authorships.select { |a| a.orcid_resource_identifier.present? }
      .max_by(&:updated_by_owner)
      .try(:orcid_resource_identifier)
  end

  def confirmed_value_to_keep
    !!authorships.detect { |a| a.confirmed.present? }
  end

  def role_to_keep
    authorships.detect { |a| a.role.present? }.try(:role)
  end

  def oa_timestamp_to_keep
    authorships.select { |a| a.open_access_notification_sent_at.present? }
      .max_by(&:open_access_notification_sent_at)
      .try(:open_access_notification_sent_at)
  end

  def owner_update_timestamp_to_keep
    authorships.select { |a| a.updated_by_owner_at.present? }
      .max_by(&:updated_by_owner_at)
      .try(:updated_by_owner_at)
  end

  def waiver_to_keep
    authorships.select { |a| a.waiver.present? }
      .max_by(&:updated_by_owner)
      .try(:waiver)
  end

  def waivers_to_destroy
    all_waivers = authorships.map { |a| a.waiver }
    wtd = all_waivers - [waiver_to_keep]
    wtd.compact
  end

  def visibility_value_to_keep
    authorships.max_by(&:updated_by_owner)
      .visible_in_profile
  end

  def position_value_to_keep
    authorships.select { |a| a.position_in_profile.present? }
      .max_by(&:updated_by_owner)
      .try(:position_in_profile)
  end

  def scholarsphere_deposits_to_keep
    authorships.map { |a| a.scholarsphere_work_deposits }.flatten
  end

  private

    attr_reader :authorships
end
