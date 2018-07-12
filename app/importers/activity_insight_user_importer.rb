class ActivityInsightUserImporter < CSVImporter

  def row_to_object(row)
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

  def bulk_import(objects)
    User.import(objects)
  end
end
