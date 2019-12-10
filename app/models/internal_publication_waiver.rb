class InternalPublicationWaiver
  include ActiveModel::Model

  attr_accessor :authorship

  delegate :title, :abstract, :doi, :published_by, to: :authorship, prefix: false
end
