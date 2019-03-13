class ActivityInsightEducationHistoryImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    user = User.find_by(webaccess_id: row[:username].downcase)

    if user
      EducationHistoryItem.new(user: user,
                               activity_insight_identifier: row[:record_id],
                               degree: row[:degree],
                               explanation_of_other_degree: row[:explaination_of_other_degree],
                               is_honorary_degree: row[:is_this_an_honary_degree],
                               is_highest_degree_earned: row[:highest_degree_earned?],
                               institution: row[:institution],
                               school: row[:"college/school"],
                               location_of_institution: row[:location_of_institution],
                               emphasis_or_major: row[:"emphasis/major"],
                               supporting_areas_of_emphasis: row[:supporting_areas_of_emphasis],
                               dissertation_or_thesis_title: row[:"dissertation/thesis_title"],
                               honor_or_distinction: row[:"honor/distinction"],
                               description: row[:description],
                               comments: row[:comments],
                               start_year: row[:start_year],
                               end_year: row[:end_year])
    end
  end

  def bulk_import(objects)
    EducationHistoryItem.import objects,
                                on_duplicate_key_update: {conflict_target: [:activity_insight_identifier],
                                                          columns: [:degree,
                                                                    :explanation_of_other_degree,
                                                                    :is_honorary_degree,
                                                                    :is_highest_degree_earned,
                                                                    :institution,
                                                                    :school,
                                                                    :location_of_institution,
                                                                    :emphasis_or_major,
                                                                    :supporting_areas_of_emphasis,
                                                                    :dissertation_or_thesis_title,
                                                                    :honor_or_distinction,
                                                                    :description,
                                                                    :comments,
                                                                    :start_year,
                                                                    :end_year]}
  end
end
