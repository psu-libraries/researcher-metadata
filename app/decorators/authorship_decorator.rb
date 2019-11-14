class AuthorshipDecorator < SimpleDelegator
  def class
    __getobj__.class
  end

  def label
    if publication_open_access_url
      %{<a href="#{publication_open_access_url}" target="_blank">#{publication_title}</a> - #{publication_published_by} - #{publication_year}}
    else
      "#{publication_title} - #{publication_published_by} - #{publication_year}"
    end
  end
end
