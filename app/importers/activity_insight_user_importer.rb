class ActivityInsightUserImporter < CSVImporter

  def row_to_object(row)
    webaccess_id = row[:username].downcase

    unless User.find_by(webaccess_id: webaccess_id)
      u = User.new
      u.first_name = row[:first_name]
      u.middle_name = row[:middle_name]
      u.last_name = row[:last_name]
      u.institution = 'Penn State University'
      u.webaccess_id = webaccess_id
      u.activity_insight_identifier = row[:user_id]
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
