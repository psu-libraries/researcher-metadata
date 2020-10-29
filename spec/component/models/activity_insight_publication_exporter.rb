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
                      published_on: Date.parse('01/01/01'),
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
        exporter_object = exporter.new([publication], 'beta')
        allow(HTTParty).to receive(:post).and_return response
        expect_any_instance_of(Logger).to receive(:info).with(/started at|ended at/).twice
        expect_any_instance_of(Logger).to receive(:error).with(/Unexpected EOF in prolog/)
        exporter_object.export
      end
    end

    context 'when 200 code is returned from DM' do
      let(:response) do
        double 'httparty_response',
               code: 200,
               to_s: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n<Success/>\n"
      end

      it 'does not log any errors' do
        exporter_object = exporter.new([publication], 'beta')
        allow(HTTParty).to receive(:post).and_return response
        expect_any_instance_of(Logger).to receive(:info).with(/started at|ended at/).twice
        expect_any_instance_of(Logger).not_to receive(:error)
        exporter_object.export
      end
    end
  end
end
