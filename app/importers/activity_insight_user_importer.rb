class ActivityInsightUserImporter < CSVImporter

  def row_to_object(row)
    p = Person.new
    p.first_name = row[:first_name]
    p.middle_name = row[:middle_name]
    p.last_name = row[:last_name]
    p.institution = 'Penn State University'
    p.build_user(webaccess_id: row[:username])
#   p.email = row[:email]
#   p.campus_abbreviation = row[:campus]
#   p.campus_name = row[:campus_name]
#   p.college_abbreviation = row[:college]
#   p.college_name = row[:college_name]
#   p.department = row[:department]
#   p.division = row[:division]
#   p.institute = row[:institute]
#   p.school = row[:school]
    p
  end

  def bulk_import(objects)
    Person.import(objects, recursive: true)
  end
end
