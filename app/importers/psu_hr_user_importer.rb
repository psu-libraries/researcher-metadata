class PSUHRUserImporter < CSVImporter
  def row_to_object(row)
    if row[:accessid]
      webaccess_id = row[:accessid].downcase
      existing_user = User.find_by(webaccess_id: webaccess_id)

      if organization(row)
        if existing_user
          ActiveRecord::Base.transaction do
            if existing_user.organizations.none?
              m = UserOrganizationMembership.new
              m.organization = organization(row)
              m.user = existing_user
              m.import_source = 'HR'
              m.started_on = row[:academic_appointment_start_date]
              m.save!
            end
          end
        else
          ActiveRecord::Base.transaction do
            u = User.new
            u.webaccess_id = webaccess_id
            u.first_name = first_name(row)
            u.last_name = last_name(row)
            u.penn_state_identifier = row[:psuid]
            u.save!

            m = UserOrganizationMembership.new
            m.organization = organization(row)
            m.user = u
            m.import_source = 'HR'
            m.started_on = row[:academic_appointment_start_date]
            m.save!
          end
        end
      end
    end
    nil
  end

  def bulk_import(objects)
    # We're persisting one record at a time as we iterate over each row since we
    # also need to create associated records.
  end

  private

  def first_name(row)
    row[:academic_appointee].split(' ')[0].strip
  end

  def last_name(row)
    row[:academic_appointee].split(' ')[1].strip
  end

  def organization(row)
    case row[:academic_unit_for_primary_academic_appointment]
    when 'Penn State Law'
      law_school_org
    when 'Dickinson Law'
      dickinson_org
    else
      nil
    end
  end

  def law_school_org
    @law_school_org ||= Organization.find_by(pure_external_identifier: 'COLLEGE-PL')
  end

  def dickinson_org
    @dickinson_org ||= Organization.find_by(pure_external_identifier: 'CAMPUS-DN')
  end
end
