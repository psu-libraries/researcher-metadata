# frozen_string_literal: true

class ActivityInsightPostprintStatusService
  def self.sync
    pubs_to_set_openly_available = Publication.left_joins(:open_access_locations).where(activity_insight_postprint_status: 'In Progress').where('open_access_status IN (?) OR open_access_locations.url ILIKE ?', ['gold', 'hybrid'], '%scholarsphere.psu%').distinct
    pubs_to_set_openly_available.each do |pub|
      pub.update_column(:activity_insight_postprint_status, 'Already Openly Available')
      pub.activity_insight_oa_files.each { |file| AiOAStatusExportJob.perform_later(file.id, 'Already Openly Available') }
    end

    pubs_to_set_status = Publication.joins(:activity_insight_oa_files).where(activity_insight_postprint_status: nil).distinct
    pubs_to_set_status.each do |pub|
      if pub.open_access_locations.any? { |loc| loc.source == Source::SCHOLARSPHERE } || pub.open_access_status == 'gold' || pub.open_access_status == 'hybrid'
        pub.update_column(:activity_insight_postprint_status, 'Already Openly Available')
        pub.activity_insight_oa_files.each { |file| AiOAStatusExportJob.perform_later(file.id, 'Already Openly Available') }
      elsif pub.is_oa_publication?
        pub.update_column(:activity_insight_postprint_status, 'In Progress')
        pub.activity_insight_oa_files.each do |file|
          AiOAStatusExportJob.perform_later(file.id, 'In Progress')
          PublicationDownloadJob.perform_later(file.id) if file.file_download_location.blank?
        end
      end
    end

    pubs_to_remove_status = Publication.where(activity_insight_postprint_status: 'In Progress').left_joins(:activity_insight_oa_files).where(activity_insight_oa_files: { file_download_location: nil })
    pubs_to_remove_status.each { |pub| pub.update_column(:activity_insight_postprint_status, nil) unless pubs_to_set_openly_available.include?(pub) || pubs_to_set_status.include?(pub) }
  end
end
