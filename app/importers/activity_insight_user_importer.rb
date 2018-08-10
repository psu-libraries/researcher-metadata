class ActivityInsightUserImporter < CSVImporter

  def row_to_object(row)
    webaccess_id = row[:username].downcase
    existing_user = User.find_by(webaccess_id: webaccess_id)

    if existing_user
      # We trust that Activity Insight is the best import source for this data that we
      # currently have. If we find an existing record with the same webaccess_id, we
      # go ahead and update our data with whatever is currently in Activity Insight
      # regardless of other import data sources. Since the Activity Insight source data
      # doesn't contain information about when the data was last updated in Activity Insight,
      # we re-import every record each time the import is run. However, if a user record has
      # been manually edited, we don't update it with imported data.
      if existing_user.updated_by_user_at.blank?
        existing_user.first_name = row[:first_name]
        existing_user.middle_name = row[:middle_name]
        existing_user.last_name = row[:last_name]
        existing_user.penn_state_identifier = row[:'psu_id_#']
        existing_user.activity_insight_identifier = row[:user_id]
        existing_user
      else
        nil
      end
    else
      u = User.new
      u.first_name = row[:first_name]
      u.middle_name = row[:middle_name]
      u.last_name = row[:last_name]
      u.webaccess_id = webaccess_id
      u.penn_state_identifier = row[:'psu_id_#']
      u.activity_insight_identifier = row[:user_id]
      u
    end
  end

  def bulk_import(objects)
    unique_users = objects.uniq { |o| o.webaccess_id.downcase }
    if objects.count != unique_users.count
      fatal_errors << "The file contains at least one duplicate user."
    end
    User.import unique_users,
                on_duplicate_key_update: {conflict_target: [:webaccess_id],
                                          columns: [:first_name,
                                                    :middle_name,
                                                    :last_name,
                                                    :penn_state_identifier,
                                                    :activity_insight_identifier]}
  end
end
