# frozen_string_literal: true

class ExportMetadataLinkComponent < ViewComponent::Base
  attr_reader :publication

  def initialize(publication:)
    @publication = publication
  end

  def scholarsphere_export_failed?
    publication.scholarsphere_upload_failed?
  end
end
