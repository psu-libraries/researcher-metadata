require 'component/component_spec_helper'

describe ActivityInsightPublicationExporter do
  subject(:exporter) { ActivityInsightPublicationExporter }

  let!(:user) { FactoryBot.create :user, activity_insight_identifier: '123456' }
  let!(:authorship) { FactoryBot.create :authorship, user: user, publication: publication }
  let!(:publication) do
    FactoryBot.create(:publication,
                      secondary_title: 'Second Title',
                      status: 'Published',
                      journal_title: 'Journal Title',
                      volume: '1',
                      published_on: Date.yesterday,
                      issue: '2',
                      edition: '123',
                      abstract: 'Abstract',
                      page_range: '1-2',
                      total_scopus_citations: '3',
                      authors_et_al: true,
                      user_submitted_open_access_url: 'site.org',
                      isbn: '123-123-123')
  end
  let!(:contributor) { FactoryBot.create :contributor, publication: publication }

  describe '#to_xml' do
    it 'generates xml' do
      exporter_object = exporter.new([], 'beta')
      expect(exporter_object.send(:to_xml, publication)).to eq fixture('activity_insight_export.xml').read
    end
  end
end
