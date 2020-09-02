class PSULawSchoolUserImporter < CSVImporter
  def row_to_object(row)
    webaccess_id = row[:accessid].downcase
    existing_user = User.find_by(webaccess_id: webaccess_id)

    if existing_user
      unless existing_user.updated_by_user_at
        ActiveRecord::Base.transaction do
          if existing_user.penn_state_identifier.blank?
            existing_user.update_attributes!(penn_state_identifier: row[:psuid]) 
          end

          if existing_user.organizations.none?
            existing_user.organizations << organization(row)
          end
        end
      end
    else
      ActiveRecord::Base.transaction do
        u = User.new
        u.first_name = first_name(row)
        u.last_name = last_name(row)
        
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
    end
  end

  def law_school_org
    @law_school_org ||= Organization.find_by(pure_external_identifier: 'COLLEGE-PL')
  end

  def dickinson_org
    @dickinson_org ||= Organization.find_by(pure_external_identifier: 'CAMPUS-DN')
  end
end
