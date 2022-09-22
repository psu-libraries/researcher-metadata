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
    # TODO: check if these can be moved to cache so we can retrieve later
    # uploader = ScholarsphereFileUploader.new
    # uploads.values.each do |upload|
    #   uploader.store!(upload['file'])
    # end
    # uploader.retrieve_from_store!(uploads.values.first['file'].original_filename)
    uploads.values.map { |upload| { original_filename: upload['file'].original_filename, temp_path: upload['file'].path } }
  end
end
