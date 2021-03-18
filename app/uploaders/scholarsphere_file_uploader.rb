class ScholarsphereFileUploader < CarrierWave::Uploader::Base
  storage :file

  def root
    Rails.root
  end

  def store_dir
    if Rails.env.test?
      "tmp/uploads/scholarsphere_file_uploads/#{model.id}/file"
    else
      "uploads/scholarsphere_file_uploads/#{model.id}/file"
    end
  end

  def cache_dir
    if Rails.env.test?
      "tmp/uploads/cache/scholarsphere_file_uploads/#{model.id}/file"
    else
      "uploads/cache/scholarsphere_file_uploads/#{model.id}/file"
    end
  end
end
