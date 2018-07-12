class ActivityInsightUserImporter < CSVImporter

  def row_to_object(row)
    unless User.find_by(webaccess_id: row[:username])
      u = User.new
      u.first_name = row[:first_name]
      u.middle_name = row[:middle_name]
      u.last_name = row[:last_name]
      u.institution = 'Penn State University'
      u.webaccess_id = row[:username]
  #   u.email = row[:email]
  #   u.campus_abbreviation = row[:campus]
  #   u.campus_name = row[:campus_name]
  #   u.college_abbreviation = row[:college]
  #   u.college_name = row[:college_name]
  #   u.department = row[:department]
  #   u.division = row[:division]
  #   u.institute = row[:institute]
  #   u.school = row[:school]
      u
    end
  end

  def bulk_import(objects)
    unique_users = objects.uniq { |o| o.webaccess_id }
    if objects.count != unique_users.count
      fatal_errors << "The file contains at least one duplicate user."
    end
    User.import(unique_users)
  end
end
