# frozen_string_literal: true

class AuthorshipDecorator < BaseDecorator
  def initialize(authorship, view_context = nil)
    @view_context = view_context
    super(authorship)
  end

  def label
    wrap_title(pub_title)
  end

  def profile_management_label
    wrap_title(profile_management_pub_title)
  end

  def open_access_status_icon
    return 'circle-o-notch' unless published?

    return 'unlock-alt' if preferred_open_access_url.present?

    if scholarsphere_upload_pending?
      'hourglass-half'
    elsif
      activity_insight_upload_processing?
      'upload'
    elsif scholarsphere_upload_failed?
      'exclamation-circle'
    elsif open_access_waived?
      'lock'
    else
      'question'
    end
  end

  def open_access_status_icon_alt_text
    case open_access_status_icon
    when 'unlock-alt'
      'known open access version'
    when 'lock'
      'Open access obligations waived'
    when 'hourglass-half'
      'Upload to ScholarSphere pending'
    when 'exclamation-circle'
      'Scholarsphere upload failed. Please try again'
    when 'circle-o-notch'
      'Publication is in press and will not be subject to the open access policy until published'
    when 'upload'
      'A file for the publication was uploaded in Activity Insight and is being processed for deposit in ScholarSphere.'
    else
      'open access status currently unknown. Click publication title link to add information or submit a waiver'
    end
  end

  def exportable_to_orcid?
    !!user.orcid_access_token && publication.orcid_allowed? && confirmed
  end

  private

    attr_reader :view_context

    def pub_title
      if preferred_open_access_url.present?
        %{<a href="#{preferred_open_access_url}" target="_blank">#{title}</a>}
      else
        title
      end
    end

    def profile_management_pub_title
      if no_open_access_information? && is_oa_publication? && published? && confirmed
        view_context.link_to title, view_context.edit_open_access_publication_path(publication)
      else
        title
      end
    end

    def wrap_title(title)
      l = %{<span class="publication-title">#{title}</span>}
      l += %{, <span class="journal-name">#{published_by}</span>} if published_by.present?
      l += ", #{year}" if year.present?
      l
    end
end
