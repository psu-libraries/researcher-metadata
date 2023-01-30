# frozen_string_literal: true

require 'component/component_spec_helper'

RSpec.describe ActivityInsightOaDashboardComponent, type: :component do
  let!(:aif1) { create :activity_insight_oa_file, publication: pub1 }
  let!(:aif2) { create :activity_insight_oa_file, publication: pub2 }

  context 'when no publications need their doi verified' do
    let!(:oal) { create :open_access_location, publication: pub2 }
    let!(:pub1) { create :publication, doi_verified: true }
    let!(:pub2) { create :publication, doi_verified: nil }

    it 'renders a muted card with no link' do
      render_inline(described_class.new)
      expect(rendered_component).to have_css('.text-muted')
      expect(rendered_component).to have_css('.text-large', text: '0')
      expect(rendered_component).not_to have_link(href: '/activity_insight_oa_workflow/doi_verification')
    end
  end

  context 'when publications need their doi verified' do
    let!(:pub1) { create :publication, doi_verified: false }
    let!(:pub2) { create :publication, doi_verified: nil }

    it 'renders the doi check card with a link and the number of publications in the corner' do
      render_inline(described_class.new)
      expect(rendered_component).not_to have_css('.text-muted')
      expect(rendered_component).to have_css('.text-large', text: '2')
      expect(rendered_component).to have_link(href: '/activity_insight_oa_workflow/doi_verification')
    end
  end
end
