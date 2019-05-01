class ActivityInsightUserProfileImporter < ActivityInsightCSVImporter

  def row_to_object(row)
    webaccess_id = row[:username].downcase
    existing_user = User.find_by(webaccess_id: webaccess_id)

    if existing_user && existing_user.updated_by_user_at.blank?
      existing_user.ai_teaching_interests = row[:teaching_interests]
      existing_user.ai_research_interests = row[:research_interests]
      existing_user
    else
      nil
    end
  end

  def bulk_import(objects)
    User.import objects,
                on_duplicate_key_update: {conflict_target: [:webaccess_id],
                                          columns: [:ai_teaching_interests,
                                                    :ai_research_interests]}
  end
end
