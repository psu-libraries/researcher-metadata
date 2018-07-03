class ActivityInsightAuthorshipImporter < CSVImporter

  def call
    tf = Tempfile.new('temp_publications')

    File.foreach(filename).with_index do |line, i|
      if i == 0
        headers = line.strip.gsub('"', '').split(',')
        header_counts = {}

        headers.each do |header|
          if header_counts.has_key?(header)
            header_counts[header] += 1
          else
            header_counts[header] = 1
          end
        end

        new_headers = []

        headers.reverse.each do |header|
          if header_counts[header] == 1
            new_headers.push(header)
          else
            new_headers.push(header + header_counts[header].to_s)
            header_counts[header] -= 1
          end
        end

        new_header_row = new_headers.reverse.map { |h| "\"#{h}\"" }.join(',')
        tf.puts new_header_row
      else
        tf.puts line
      end
    end

    self.filename = tf.path

    super

    tf.unlink
  end

  def row_to_object(row)

    authorship = Authorship.new

    if row[:faculty_name].present?
      authorship.person = Person.find_by(activity_insight_identifier: row[:user_id])
    else
      p = Person.find_or_create_by!(first_name: row[:fname], middle_name: row[:mname], last_name: row[:lname])
      authorship.person = p
    end
    authorship.publication = Publication.find_by(activity_insight_identifier: row[:parent_id])
    authorship.author_number = row[:ordinal].to_i
    authorship.activity_insight_identifier = row[:id]
    authorship
  end

  def bulk_import(objects)
    Authorship.import(objects)
  end

  private

  def encoding
    'bom|utf-8'
  end
end
