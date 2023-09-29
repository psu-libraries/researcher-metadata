# frozen_string_literal: true

require 'component/component_spec_helper'

describe ActivityInsightPublicationExporter do
  subject(:exporter) { described_class }

  let!(:user) { create(:user, webaccess_id: 'abc123', activity_insight_identifier: '123456') }
  let!(:authorship1) { create(:authorship, user: user, publication: publication1) }
  let!(:authorship2) { create(:authorship, user: user, publication: publication2) }
  let!(:publication1) do
    create(:publication,
           id: 1,
           secondary_title: 'Second Title',
           status: 'Published',
           journal_title: 'Journal Title',
           volume: '1',
           published_on: Date.parse('01/01/01'),
           issue: '2',
           edition: '123',
           abstract: 'Abstract',
           page_range: '1-2',
           total_scopus_citations: '3',
           authors_et_al: true,
           open_access_locations: [
             build(:open_access_location, :user, url: 'site.org')
           ],
           isbn: '123-123-123')
  end
  let!(:publication2) { create(:publication, id: 2) }
  let!(:publication3) { create(:publication, id: 3, exported_to_activity_insight: true) }
  let!(:ai_import) do
    create(:publication_import, publication: publication2,
                                source: 'Activity Insight', source_identifier: 'ai_id_1')
  end
  let!(:contributor_name1) { create(:contributor_name, publication: publication1) }
  let!(:contributor_name2) { create(:contributor_name, publication: publication2) }

  describe '#to_xml' do
    it 'generates xml' do
      exporter_object = exporter.new([], 'beta')
      expect(exporter_object.send(:to_xml, publication1)).to eq fixture('activity_insight_publication_export.xml').read
    end
  end

  describe '#webservice_url' do
    let(:beta_url) do
      'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    end
    let(:production_url) do
      'https://webservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    end

    context 'when target is "beta"' do
      it 'returns beta url' do
        exporter_object = exporter.new([], 'beta')
        expect(exporter_object.send(:webservice_url)).to eq beta_url
      end
    end

    context 'when target is "production"' do
      it 'returns production url' do
        exporter_object = exporter.new([], 'production')
        expect(exporter_object.send(:webservice_url)).to eq production_url
      end
    end
  end

  describe '#export' do
    context 'when 400 code is returned from DM' do
      let(:response) do
        double 'httparty_response',
               code: 400,
               to_s: '<?xml version="1.0" encoding="UTF-8"?>

<Error>The following errors were detected:
	<Message>Unexpected EOF in prolog
 at [row,col {unknown-source}]: [1,0] Nested exception: Unexpected EOF in prolog
 at [row,col {unknown-source}]: [1,0]</Message>
</Error>'
      end

      it 'logs DM webservice responses' do
        exporter_object = exporter.new([publication1], 'beta')
        allow(HTTParty).to receive(:post).and_return response
        expect_any_instance_of(Logger).to receive(:info).with(/started at|ended at|Publications not/).exactly(3).times
        expect_any_instance_of(Logger).to receive(:error).with(/Unexpected EOF|lication ID: #{publication1.id}/).twice
        exporter_object.export
      end
    end

    context 'when 200 code is returned from DM' do
      let(:response) do
        double 'httparty_response',
               code: 200,
               to_s: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n<Success/>\n"
      end

      context 'when exporting to beta' do
        it 'does not log any errors and does not update #exported_to_activity_insight' do
          exporter_object = exporter.new([publication1], 'beta')
          allow(HTTParty).to receive(:post).and_return response
          expect_any_instance_of(Logger).to receive(:info).with(/started at|ended at|Publications not/).exactly(3).times
          expect_any_instance_of(Logger).not_to receive(:error)
          expect { exporter_object.export }.not_to change(publication1, :exported_to_activity_insight)
        end
      end

      context 'when exporting to production' do
        it 'does not log any errors and updates #exported_to_activity_insight' do
          exporter_object = exporter.new([publication1], 'production')
          allow(HTTParty).to receive(:post).and_return response
          expect_any_instance_of(Logger).to receive(:info).with(/started at|ended at|Publications not/).exactly(3).times
          expect_any_instance_of(Logger).not_to receive(:error)
          expect { exporter_object.export }.to change(publication1, :exported_to_activity_insight).to true
        end
      end
    end

    context 'when publication has ai_import_identifiers' do
      it "skips that publication and records that record's id in the logs" do
        exporter_object = exporter.new([publication2], 'beta')
        expect_any_instance_of(Logger).to receive(:info).with(/started at|ended at|#{publication2.id}/).exactly(3).times
        expect(HTTParty).not_to receive(:post)
        exporter_object.export
      end
    end

    context 'when publication.exported_to_activity_insight is true' do
      it "skips that publication and records that record's id in the logs" do
        exporter_object = exporter.new([publication3], 'beta')
        expect_any_instance_of(Logger).to receive(:info).with(/started at|ended at|#{publication3.id}/).exactly(3).times
        expect(HTTParty).not_to receive(:post)
        exporter_object.export
      end
    end
  end
end
