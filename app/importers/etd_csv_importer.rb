class ETDCSVImporter < CSVImporter

  def row_to_object(row)
    webaccess_id = row[:access_id].downcase
    existing_etd = ETD.find_by(webaccess_id: webaccess_id)

    if existing_etd
      if existing_etd.updated_by_user_at.blank?
        existing_etd.attributes = etd_attrs(row)
        existing_etd
      else
        nil
      end
    else
      etd = ETD.new(etd_attrs(row))
      etd
    end
  end

  def bulk_import(objects)
    unique_etds = objects.uniq { |o| o.webaccess_id.downcase }
    if objects.count != unique_etds.count
      fatal_errors << "The file contains at least one duplicate ETD."
    end
    ETD.import(
      unique_etds,
      on_duplicate_key_update: {
          conflict_target: [:webaccess_id],
          columns: [
            :external_identifier,
            :year,
            :access_level,
            :author_first_name,
            :author_middle_name,
            :author_last_name,
            :title,
            :url,
            :submission_type
          ]
        }
      )
  end

  private

  def etd_attrs(row)
    {
      external_identifier: row[:submission_id],
      year: row[:submission_year],
      access_level: row[:submission_acccess_level],
      author_first_name: row[:first_name],
      author_middle_name: row[:middle_name],
      author_last_name: row[:last_name],
      webaccess_id: row[:access_id],
      title: row[:submission_title],
      url: etd_url(row[:submission_id], row[:access_id]),
      submission_type: etd_submission_type(row[:degree_name])
    }
  end

  def etd_url(submission_id, webaccess_id)
    "https://etda.libraries.psu.edu/catalog/#{submission_id}#{webaccess_id}"
  end

  def etd_submission_type(degree_name)
    submission_types[degree_name]
  end

  def submission_types
    {
      'PHD' => 'Dissertation',
      'DED' => 'Dissertation',
      'MA' => 'Master Thesis',
      'MArch' => 'Master Thesis',
      'ME' => 'Master Thesis',
      'MS' => 'Master Thesis',
      'DMA' => 'Dissertation',
      'MLA' => 'Master Thesis',
      'M Ed' => 'Master Thesis',
      'M AGR' => 'Master Thesis',
      'Biomedical Sciences' => 'Master Thesis',
      'Master of Architecture' => 'Master Thesis',
      'Electrical Engineering' => 'Master Thesis'
    }
  end
end
