# frozen_string_literal: true

class ScholarsphereFileUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    if Rails.env.test?
      Rails.root.join "tmp/uploads/scholarsphere_file_uploads/#{model&.id || object_id}/file"
    else
      Rails.root.join "uploads/scholarsphere_file_uploads/#{model&.id || object_id}/file"
    end
  end

  def cache_dir
    if Rails.env.test?
      Rails.root.join "tmp/uploads/cache/scholarsphere_file_uploads/#{model&.id || object_id}/file"
    else
      Rails.root.join "uploads/cache/scholarsphere_file_uploads/#{model&.id || object_id}/file"
    end
  end
end
