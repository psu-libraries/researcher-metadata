# frozen_string_literal: true

require 'component/component_spec_helper'

RSpec.describe DOIVerificationComponent, type: :component do
  let!(:aif1) { create(:activity_insight_oa_file, publication: pub1) }
  let!(:aif2) { create(:activity_insight_oa_file, publication: pub2) }

  describe 'listing publications that need their DOIs verified' do
    let!(:pub1) { create(:publication, doi_verified: false) }
    let!(:pub2) { create(:publication, doi_verified: nil) }

    it 'show a table with header and the proper data for the publications in the table' do
      render_inline(described_class.new)
      expect(rendered_component).to have_text(pub1.title)
      expect(rendered_component).to have_text(pub1.doi)
      expect(rendered_component).to have_text('Failed Verification')
      expect(rendered_component).to have_text(pub2.title)
      expect(rendered_component).to have_text(pub2.doi)
      expect(rendered_component).to have_text('Unchecked')
      expect(rendered_component).to have_css('tr').exactly(3).times
    end
  end
end
