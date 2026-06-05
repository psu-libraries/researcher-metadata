# frozen_string_literal: true

require 'component/component_spec_helper'

RSpec.describe ExportMetadataLinkComponent, type: :component do
  let(:publication) { create(:publication) }

  context 'when a ScholarSphere export failed' do
    let(:authorship) { create(:authorship, publication: publication) }

    before do
      create(:scholarsphere_work_deposit, authorship: authorship, status: 'Failed')
      render_inline(described_class.new(publication: publication))
    end

    it 'shows a warning alert with contact information' do
      expect(rendered_content).to have_css('.alert.alert-warning')
      expect(rendered_content).to have_text(I18n.t('components.export_metadata_link_component.failed_message_html',
                                                   email_link: 'openaccess@psu.edu'))
      expect(rendered_content).to have_link('openaccess@psu.edu', href: 'mailto:openaccess@psu.edu')
    end

    it 'does not show the deposit button' do
      expect(rendered_content).to have_no_button(I18n.t('components.export_metadata_link_component.deposit_button'))
    end
  end

  context 'when a ScholarSphere export has not failed' do
    before do
      render_inline(described_class.new(publication: publication))
    end

    it 'shows the deposit button' do
      expect(rendered_content).to have_button(I18n.t('components.export_metadata_link_component.deposit_button'))
    end

    it 'does not show a warning alert' do
      expect(rendered_content).to have_no_css('.alert.alert-warning')
    end
  end
end
