# frozen_string_literal: true

class AuthorshipMergePolicy
  def initialize(authorships)
    @authorships = authorships
  end

  def orcid_resource_id_to_keep
    authorships.select { |a| a.orcid_resource_identifier.present? }
      .sort_by(&:updated_by_owner)
      .last.try(:orcid_resource_identifier)
  end

  def confirmed_value_to_keep
    !!authorships.find { |a| a.confirmed.present? }
  end

  def role_to_keep
    authorships.find { |a| a.role.present? }.try(:role)
  end

  def oa_timestamp_to_keep
    authorships.select { |a| a.open_access_notification_sent_at.present? }
      .sort_by(&:open_access_notification_sent_at)
      .last.try(:open_access_notification_sent_at)
  end

  def owner_update_timestamp_to_keep
    authorships.select { |a| a.updated_by_owner_at.present? }
      .sort_by(&:updated_by_owner_at)
      .last.try(:updated_by_owner_at)
  end

  def waiver_to_keep
    authorships.select { |a| a.waiver.present? }
      .sort_by(&:updated_by_owner)
      .last.try(:waiver)
  end

  def waivers_to_destroy
    all_waivers = authorships.map(&:waiver)
    wtd = all_waivers - [waiver_to_keep]
    wtd.compact
  end

  def visibility_value_to_keep
    authorships.sort_by(&:updated_by_owner)
      .last.visible_in_profile
  end

  def position_value_to_keep
    authorships.select { |a| a.position_in_profile.present? }
      .sort_by(&:updated_by_owner)
      .last.try(:position_in_profile)
  end

  def scholarsphere_deposits_to_keep
    authorships.map(&:scholarsphere_work_deposits).flatten
  end

  private

    attr_reader :authorships
end
