class AuthorshipDecorator < SimpleDelegator
  def initialize(authorship, view_context = nil)
    @view_context = view_context
    super(authorship)
  end

  def class
    __getobj__.class
  end

  def label
    wrap_title(pub_title)
  end

  def profile_management_label
    wrap_title(profile_management_pub_title)
  end

  def open_access_status_icon
    if preferred_open_access_url.blank?
      if scholarsphere_upload_pending?
        'hourglass-half'
      elsif scholarsphere_upload_failed?
        'exclamation-circle'
      else
        if open_access_waived?
          'lock'
        else
          'question'
        end
      end
    else
      'unlock-alt'
    end
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
    if no_open_access_information? && is_journal_article?
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
