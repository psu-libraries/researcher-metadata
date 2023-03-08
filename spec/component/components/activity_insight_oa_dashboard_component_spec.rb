# frozen_string_literal: true

require 'component/component_spec_helper'

RSpec.describe ActivityInsightOADashboardComponent, type: :component do
  let!(:aif1) { create(:activity_insight_oa_file, publication: pub1, version: 'unknown') }
  let!(:aif2) { create(:activity_insight_oa_file, publication: pub2, version: 'unknown') }

  context 'when no publications need their doi verified' do
    let!(:oal) { create(:open_access_location, publication: pub2) }
    let!(:pub1) { create(:publication, doi_verified: true) }
    let!(:pub2) { create(:publication, doi_verified: nil) }

    it 'renders a muted card with no link' do
      render_inline(described_class.new)
      expect(page.find_by_id('doi-verification-card').to_json).to include('text-muted')
      expect(page.find_by_id('doi-verification-card').text).to include('0')
      expect(rendered_component).not_to have_link(href: '/activity_insight_oa_workflow/doi_verification')
    end
  end

  context 'when publications need their doi verified' do
    let!(:pub1) { create(:publication, doi_verified: false) }
    let!(:pub2) { create(:publication, doi_verified: nil) }

    it 'renders the doi check card with a link and the number of publications in the corner' do
      render_inline(described_class.new)
      expect(page.find_by_id('doi-verification-card').to_json).not_to include('text-muted')
      expect(page.find_by_id('doi-verification-card').text).to include('1')
      expect(rendered_component).to have_link(href: '/activity_insight_oa_workflow/doi_verification')
    end
  end

  context 'when no publications need their file versions verified' do
    let!(:oal) { create(:open_access_location, publication: pub1) }
    let!(:pub1) { create(:publication, preferred_version: 'acceptedVersion') }
    let!(:pub2) { create(:publication, preferred_version: nil) }

    it 'renders a muted card with no link' do
      render_inline(described_class.new)
      expect(page.find_by_id('file-version-check-card').to_json).to include('text-muted')
      expect(page.find_by_id('file-version-check-card').text).to include('0')
      expect(rendered_component).not_to have_link(href: '/activity_insight_oa_workflow/file_version_review')
    end
  end

  context 'when publications need their file versions verified' do
    let!(:pub1) { create(:publication, preferred_version: 'acceptedVersion') }
    let!(:pub2) { create(:publication, preferred_version: 'publishedVersion') }

    it 'renders the file version check card with a link and the number of publications in the corner' do
      render_inline(described_class.new)
      expect(page.find_by_id('file-version-check-card').to_json).not_to include('text-muted')
      expect(page.find_by_id('file-version-check-card').text).to include('2')
      expect(rendered_component).to have_link(href: '/activity_insight_oa_workflow/file_version_review')
    end
  end

  context 'when no publications need their permissions verified' do
    let!(:oal) { create(:open_access_location, publication: pub2) }
    let!(:pub1) { create(:publication) }
    let!(:pub2) { create(:publication, doi_verified: nil) }
    let!(:pub2) { create(:publication, permissions_last_checked_at: Time.now, licence: 'licence') }

    it 'renders a muted card with no link' do
      render_inline(described_class.new)
      expect(page.find_by_id('permissions-check-card').to_json).to include('text-muted')
      expect(page.find_by_id('permissions-check-card').text).to include('0')
      expect(rendered_component).not_to have_link(href: '/activity_insight_oa_workflow/permissions_review')
    end
  end

  context 'when publications need their permissions verified' do
    let!(:pub1) { create(:publication, permissions_last_checked_at: Time.now) }
    let!(:pub2) { create(:publication, permissions_last_checked_at: Time.now, licence: 'licence') }

    it 'renders the permissions review card with a link and the number of publications in the corner' do
      render_inline(described_class.new)
      expect(page.find_by_id('permissions-check-card').to_json).not_to include('text-muted')
      expect(page.find_by_id('permissions-check-card').text).to include('1')
      expect(rendered_component).to have_link(href: '/activity_insight_oa_workflow/permissions_review')
    end
  end
end
