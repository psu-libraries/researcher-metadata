# frozen_string_literal: true

require 'component/component_spec_helper'

describe ActivityInsightOAStatusExporter do
  subject(:exporter) { described_class }

  let!(:user) { create(:user, webaccess_id: 'abc123') }
  let(:aif1) { create(:activity_insight_oa_file, publication: pub1, intellcont_id: '123456789100', post_file_id: '123456789101', user: user) }
  let(:aif2) { create(:activity_insight_oa_file, publication: pub2, intellcont_id: '123456789102', post_file_id: '123456789103', user: user) }
  let(:pub1) { create(:publication, open_access_status: 'gold', id: 123456) }
  let(:pub2) { create(:publication, open_access_status: 'hybrid') }

  describe '#to_xml' do
    it 'generates xml' do
      exporter_object = exporter.new(aif1.id, 'Already Openly Available')
      expect(exporter_object.send(:to_xml, aif1)).to eq fixture_file_open('activity_insight_oa_status_export.xml').read
    end
  end

  describe '#webservice_url' do
    let(:beta_url) do
      'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    end

    it 'returns beta url' do
      exporter_object = exporter.new(aif1.id, 'Already Openly Available')
      expect(exporter_object.send(:webservice_url)).to eq beta_url
    end
  end

  describe '#export' do
    context 'when 400 code is returned from DM' do
      let(:response) do
        double 'httparty_response',
               code: 400,
               body: response_body
      end
      let (:response_body) { '<?xml version="1.0" encoding="UTF-8"?>
        <Error>The following errors were detected:
          <Message>Unexpected EOF in prolog
         at [row,col {unknown-source}]: [1,0] Nested exception: Unexpected EOF in prolog
         at [row,col {unknown-source}]: [1,0]</Message>
        </Error>' }

      it 'raises an error' do
        allow(HTTParty).to receive(:post).and_return response
        exporter_object = exporter.new(aif1.id, 'Already Openly Available')
        expect { exporter_object.export }.to raise_error ActivityInsightOAStatusExporter::ExportFailed, response.body
        expect(aif1.reload.exported_oa_status_to_activity_insight).to be false
      end
    end

    context 'when 200 code is returned from DM' do
      let(:response) do
        double 'httparty_response',
               code: 200,
               to_s: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n<Success/>\n"
      end

      it 'does not raise an error' do
        allow(HTTParty).to receive(:post).and_return response
        exporter_object = exporter.new(aif1.id, 'Already Openly Available')
        expect { exporter_object.export }.not_to raise_error
      end
    end
  end
end
