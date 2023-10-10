# frozen_string_literal: true

class ActivityInsightFileUploader < CarrierWave::Uploader::Base
  storage :file
  after :remove, :remove_file_directory

  def store_dir
    if Rails.env.test?
      Rails.root.join "tmp/uploads/activity_insight_file_uploads/#{model&.id || object_id}/file"
    else
      Rails.root.join "uploads/activity_insight_file_uploads/#{model&.id || object_id}/file"
    end
  end

  def cache_dir
    if Rails.env.test?
      Rails.root.join "tmp/uploads/cache/activity_insight_file_uploads/#{model&.id || object_id}/file"
    else
      Rails.root.join "uploads/cache/activity_insight_file_uploads/#{model&.id || object_id}/file"
    end
  end

  def model_object_dir
    if Rails.env.test?
      Rails.root.join "tmp/uploads/activity_insight_file_uploads/#{model&.id || object_id}"
    else
      Rails.root.join "uploads/activity_insight_file_uploads/#{model&.id || object_id}"
    end
  end

  def remove_file_directory
    FileUtils.remove_dir(model_object_dir)
  end
end
