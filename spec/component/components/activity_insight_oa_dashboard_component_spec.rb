# frozen_string_literal: true

require 'component/component_spec_helper'

RSpec.describe ActivityInsightOADashboardComponent, type: :component do
  let!(:aif1) { create(:activity_insight_oa_file, publication: pub1, version: 'unknown') }
  let!(:aif2) { create(:activity_insight_oa_file, publication: pub2, version: 'unknown') }

  context 'when no publications need their doi verified' do
    let!(:oal) { create(:open_access_location, publication: pub2, source: Source::UNPAYWALL) }
    let!(:pub1) { create(:publication, doi_verified: true) }
    let!(:pub2) { create(:publication, doi_verified: nil) }

    it 'renders a muted card with no link' do
      render_inline(described_class.new)
      expect(page.find_by_id('doi-verification-card').to_json).to include('text-muted')
      expect(page.find_by_id('doi-verification-card').text).to include('0')
      expect(rendered_content).not_to have_link(href: '/activity_insight_oa_workflow/doi_verification')
    end
  end

  context 'when publications need their doi verified' do
    let!(:pub1) { create(:publication, doi_verified: false) }
    let!(:pub2) { create(:publication, doi_verified: nil) }

    it 'renders the doi check card with a link and the number of publications in the corner' do
      render_inline(described_class.new)
      expect(page.find_by_id('doi-verification-card').to_json).not_to include('text-muted')
      expect(page.find_by_id('doi-verification-card').text).to include('1')
      expect(rendered_content).to have_link(href: '/activity_insight_oa_workflow/doi_verification')
    end
  end

  context 'when no publications need their file versions verified' do
    let!(:oal) { create(:open_access_location, publication: pub1, source: Source::SCHOLARSPHERE) }
    let!(:pub1) { create(:publication, preferred_version: 'acceptedVersion') }
    let!(:pub2) { create(:publication, preferred_version: nil) }

    it 'renders a muted card with no link' do
      render_inline(described_class.new)
      expect(page.find_by_id('file-version-check-card').to_json).to include('text-muted')
      expect(page.find_by_id('file-version-check-card').text).to include('0')
      expect(rendered_content).not_to have_link(href: '/activity_insight_oa_workflow/file_version_review')
    end
  end

  context 'when publications need their file versions verified' do
    let!(:pub1) { create(:publication, preferred_version: 'acceptedVersion') }
    let!(:pub2) { create(:publication, preferred_version: 'publishedVersion') }

    it 'renders the file version check card with a link and the number of publications in the corner' do
      render_inline(described_class.new)
      expect(page.find_by_id('file-version-check-card').to_json).not_to include('text-muted')
      expect(page.find_by_id('file-version-check-card').text).to include('2')
      expect(rendered_content).to have_link(href: '/activity_insight_oa_workflow/file_version_review')
    end
  end

  context 'when no publications have only wrong file versions' do
    let!(:oal) { create(:open_access_location, publication: pub1) }
    let!(:aif1) {
      create(
        :activity_insight_oa_file,
        publication: pub1,
        version: 'acceptedVersion'
      )
    }
    let!(:aif2) {
      create(
        :activity_insight_oa_file,
        publication: pub2,
        version: 'publishedVersion'
      )
    }
    let!(:pub1) { create(:publication, preferred_version: 'acceptedVersion') }
    let!(:pub2) { create(:publication, preferred_version: 'publishedVersion') }

    it 'renders a muted card with no link' do
      render_inline(described_class.new)
      expect(page.find_by_id('wrong-file-version-check-card').to_json).to include('text-muted')
      expect(page.find_by_id('wrong-file-version-check-card').text).to include('0')
      expect(rendered_content).not_to have_link(href: '/activity_insight_oa_workflow/wrong_file_version_review')
    end
  end

  context 'when publications have only wrong file versions' do
    let!(:aif1) {
      create(
        :activity_insight_oa_file,
        publication: pub1,
        version: 'acceptedVersion'
      )
    }
    let!(:aif2) {
      create(
        :activity_insight_oa_file,
        publication: pub2,
        version: 'publishedVersion'
      )
    }
    let!(:aif3) {
      create(
        :activity_insight_oa_file,
        publication: pub3,
        version: 'unknown'
      )
    }
    let!(:aif4) {
      create(
        :activity_insight_oa_file,
        publication: pub4,
        version: nil
      )
    }
    let!(:pub1) { create(:publication, preferred_version: 'publishedVersion') }
    let!(:pub2) { create(:publication, preferred_version: 'acceptedVersion') }
    let!(:pub3) { create(:publication, preferred_version: 'acceptedVersion') }
    let!(:pub4) { create(:publication, preferred_version: 'acceptedVersion') }

    it 'renders the file version check card with a link and the number of publications in the corner' do
      render_inline(described_class.new)
      expect(page.find_by_id('wrong-file-version-check-card').to_json).not_to include('text-muted')
      expect(page.find_by_id('wrong-file-version-check-card').text).to include('2')
      expect(rendered_content).to have_link(href: '/activity_insight_oa_workflow/wrong_file_version_review')
    end
  end

  context 'when no publications have a preferred version of none' do
    let!(:oal) { create(:open_access_location, publication: pub2, source: Source::SCHOLARSPHERE) }
    let!(:pub1) { create(:publication) }
    let!(:pub2) { create(:publication, doi_verified: nil) }
    let!(:pub3) { create(:publication, permissions_last_checked_at: Time.now, preferred_version: 'acceptedVersion') }

    it 'renders a muted card with no link' do
      render_inline(described_class.new)
      expect(page.find_by_id('preferred-file-version-none-check-card').to_json).to include('text-muted')
      expect(page.find_by_id('preferred-file-version-none-check-card').text).to include('0')
      expect(rendered_content).not_to have_link(href: '/activity_insight_oa_workflow/preferred_file_version_none_review')
    end
  end

  context 'when publications have a preferred version of none' do
    let!(:pub1) { create(:publication, permissions_last_checked_at: Time.now) }
    let!(:pub2) {
      create(
        :publication,
        permissions_last_checked_at: Time.now,
        preferred_version: 'None'
      )
    }

    it 'renders the preferred version review card with a link and the number of publications in the corner' do
      render_inline(described_class.new)
      expect(page.find_by_id('preferred-file-version-none-check-card').to_json).not_to include('text-muted')
      expect(page.find_by_id('preferred-file-version-none-check-card').text).to include('1')
      expect(rendered_content).to have_link(href: '/activity_insight_oa_workflow/preferred_file_version_none_review')
    end
  end

  context 'when no publications need their preferred version verified' do
    let!(:oal) { create(:open_access_location, publication: pub2, source: Source::SCHOLARSPHERE) }
    let!(:pub1) { create(:publication) }
    let!(:pub2) { create(:publication, doi_verified: nil) }
    let!(:pub3) { create(:publication, permissions_last_checked_at: Time.now, preferred_version: 'acceptedVersion') }

    it 'renders a muted card with no link' do
      render_inline(described_class.new)
      expect(page.find_by_id('preferred-version-check-card').to_json).to include('text-muted')
      expect(page.find_by_id('preferred-version-check-card').text).to include('0')
      expect(rendered_content).not_to have_link(href: '/activity_insight_oa_workflow/preferred_version_review')
    end
  end

  context 'when publications need their preferred version verified' do
    let!(:pub1) { create(:publication, permissions_last_checked_at: Time.now) }
    let!(:pub2) {
      create(
        :publication,
        permissions_last_checked_at: Time.now,
        preferred_version: 'acceptedVersion'
      )
    }

    it 'renders the preferred version review card with a link and the number of publications in the corner' do
      render_inline(described_class.new)
      expect(page.find_by_id('preferred-version-check-card').to_json).not_to include('text-muted')
      expect(page.find_by_id('preferred-version-check-card').text).to include('1')
      expect(rendered_content).to have_link(href: '/activity_insight_oa_workflow/preferred_version_review')
    end
  end

  context 'when no publications have files that need manual permissions metadata review' do
    let(:pub1) { create(:publication) }
    let(:pub2) { create(:publication) }

    it 'renders a muted card with no link' do
      render_inline(described_class.new)
      expect(page.find_by_id('permissions-review-card').to_json).to include('text-muted')
      expect(page.find_by_id('permissions-review-card').text).to include('0')
      expect(rendered_content).not_to have_link(
        href: Rails.application.routes.url_helpers.activity_insight_oa_workflow_permissions_review_path
      )
    end
  end

  context 'when publications have files that need manual permissions metadata review' do
    let(:pub1) {
      create(
        :publication,
        preferred_version: 'acceptedVersion'
      )
    }
    let(:pub2) { create(:publication) }
    let!(:aif) {
      create(
        :activity_insight_oa_file,
        publication: pub1,
        permissions_last_checked_at: Time.now,
        version: 'acceptedVersion',
        license: nil,
        checked_for_set_statement: true,
        checked_for_embargo_date: true
      )
    }

    it 'renders the permissions metadata review card with a link and the number of publications in the corner' do
      render_inline(described_class.new)
      expect(page.find_by_id('permissions-review-card').to_json).not_to include('text-muted')
      expect(page.find_by_id('permissions-review-card').text).to include('1')
      expect(rendered_content).to have_link(
        href: Rails.application.routes.url_helpers.activity_insight_oa_workflow_permissions_review_path
      )
    end
  end

  context 'when no publications are ready for final metadata review' do
    let(:pub1) { create(:publication) }
    let(:pub2) { create(:publication) }

    it 'renders a muted card with no link' do
      render_inline(described_class.new)
      expect(page.find_by_id('metadata-check-card').to_json).to include('text-muted')
      expect(page.find_by_id('metadata-check-card').text).to include('0')
      expect(rendered_content).not_to have_link(
        href: Rails.application.routes.url_helpers.activity_insight_oa_workflow_metadata_review_path
      )
    end
  end

  context 'when publications are ready for final metadata review' do
    let(:pub1) {
      create(
        :publication,
        preferred_version: 'acceptedVersion'
      )
    }
    let(:pub2) { create(:publication) }
    let!(:aif) {
      create(
        :activity_insight_oa_file,
        publication: pub1,
        version: 'acceptedVersion',
        license: 'https://creativecommons.org/licenses/by/4.0/',
        checked_for_set_statement: true,
        checked_for_embargo_date: true,
        downloaded: true,
        file_download_location: fixture_file_open('test_file.pdf')
      )
    }

    it 'renders the metadata review card with a link and the number of publications in the corner' do
      render_inline(described_class.new)
      expect(page.find_by_id('metadata-check-card').to_json).not_to include('text-muted')
      expect(page.find_by_id('metadata-check-card').text).to include('1')
      expect(rendered_content).to have_link(
        href: Rails.application.routes.url_helpers.activity_insight_oa_workflow_metadata_review_path
      )
    end
  end

  context 'when there are publications in the workflow' do
    let!(:pub1) { create(:publication) }
    let!(:pub2) { create(:publication) }

    it 'renders the doi check card with a link and the number of publications in the corner' do
      render_inline(described_class.new)
      expect(page.find_by_id('all-workflow-publications-card').to_json).not_to include('text-muted')
      expect(page.find_by_id('all-workflow-publications-card').text).to include('2')
      expect(rendered_content).to have_link(href: '/activity_insight_oa_workflow/all_workflow_publications')
    end
  end
end
