# frozen_string_literal: true

class ExifUploads
  def self.version(uploads:, publication:)
    uploads.values.map do |upload|
      exif = ExifFileVersion.new(upload['file'].path, publication.journal.title)
      # No need to check further if it finds an Accepted Version
      return exif.version if exif.accepted_version?

      # Either Published Version or nil
      exif.version
    end.compact.uniq.first
  end

  def self.temp_files(uploads)
    uploads.values.map { |upload| { original_filename: upload['file'].original_filename, temp_path: upload['file'].path } }
  end
end
