class OrcidEmployment < OrcidResource
  def to_json(*_args)
    employment = {
      organization: {
        name: 'The Pennsylvania State University',
        address: {
          city: 'University Park',
          region: 'Pennsylvania',
          country: 'US'
        },
        "disambiguated-organization": {
          "disambiguated-organization-identifier": 'grid.29857.31',
          "disambiguation-source": 'GRID'
        }
      },
      "department-name": membership.organization_name,
      "role-title": membership.position_title,
      "start-date": {
        year: membership.started_on.year,
        month: membership.started_on.month,
        day: membership.started_on.day
      }
    }

    if membership.ended_on
      employment[:"end-date"] = {
        year: membership.ended_on.year,
        month: membership.ended_on.month,
        day: membership.ended_on.day
      }
    end

    employment.to_json
  end

  def orcid_type
    'employment'
  end

  def membership
    model
  end
end
