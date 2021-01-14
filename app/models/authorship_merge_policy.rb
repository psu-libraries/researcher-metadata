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

  private

  attr_reader :authorships
end
