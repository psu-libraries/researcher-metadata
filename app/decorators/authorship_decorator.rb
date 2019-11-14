class AuthorshipDecorator < SimpleDelegator
  def class
    __getobj__.class
  end

  def label
    "#{publication_title} - #{publication_published_by} - #{publication_year}"
  end
end
