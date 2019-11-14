class AuthorshipDecorator < SimpleDelegator
  def class
    __getobj__.class
  end

  def label
    if open_access_url
      %{<a href="#{open_access_url}" target="_blank">#{title}</a> - #{published_by} - #{year}}
    else
      "#{title} - #{published_by} - #{year}"
    end
  end
end
