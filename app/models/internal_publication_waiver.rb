class InternalPublicationWaiver
  include ActiveModel::Model

  attr_accessor :authorship, :reason_for_waiver

  delegate :title, :abstract, :doi, :published_by, to: :authorship, prefix: false

  def save!
  end
end
