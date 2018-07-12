class AddActivityInsightIdentifierToPeopleImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    webaccess_id = row[:username].downcase
    activity_insight_identifier = row[:user_id]
    user = User.find_by(webaccess_id: webaccess_id)
    user.update_column(:activity_insight_identifier, activity_insight_identifier) if user
    nil
  end

  def bulk_import(objects)
    # Do nothing
  end
end
