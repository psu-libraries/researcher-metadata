class AuthorshipDecorator < SimpleDelegator
  def class
    __getobj__.class
  end

  def label
    l = %{<span class="publication-title">#{pub_title}</span>}
    l += %{, <span class="journal-name">#{published_by}</span>} if published_by.present?
    l += ", #{year}" if year.present?
    l
  end

  private 

  def pub_title
    if preferred_open_access_url.present?
      %{<a href="#{preferred_open_access_url}" target="_blank">#{title}</a>}
    else
      title
    end
  end
end
