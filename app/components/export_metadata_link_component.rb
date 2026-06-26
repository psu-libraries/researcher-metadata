# frozen_string_literal: true

class ExportMetadataLinkComponent < ViewComponent::Base
  attr_reader :publication

  def initialize(publication:)
    @publication = publication
  end

  def scholarsphere_export_failed?
    publication.scholarsphere_upload_failed?
  end

  def failed_alert_icon
    helpers.fa_icon('exclamation-triangle')
  end

  def failed_message_html
    I18n.t('components.export_metadata_link_component.failed_message_html',
           email_link: helpers.mail_to('openaccess@psu.edu', 'openaccess@psu.edu')).html_safe
  end
end
