class ActivityInsightPublicationImporter < CSVImporter

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
    p = Publication.new
    p.title = row[:title]
    p
  end

  def bulk_import(objects)
    Publication.import(objects)
  end

  private

  def encoding
    'bom|utf-8'
  end
end
