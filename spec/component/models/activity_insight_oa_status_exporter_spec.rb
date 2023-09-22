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
      exporter_object = exporter.new([])
      expect(exporter_object.send(:to_xml, aif1)).to eq fixture('activity_insight_oa_status_export.xml').read
    end
  end

  describe '#webservice_url' do
    let(:beta_url) do
      'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    end

    it 'returns beta url' do
      exporter_object = exporter.new([])
      expect(exporter_object.send(:webservice_url)).to eq beta_url
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
        exporter_object = exporter.new([aif1])
        allow(HTTParty).to receive(:post).and_return response
        expect_any_instance_of(Logger).to receive(:info).with(/started at|ended at|Files not/).exactly(3).times
        expect_any_instance_of(Logger).to receive(:error).with(/Unexpected EOF|File ID: #{aif1.id}/).twice
        exporter_object.export
      end
    end

    context 'when 200 code is returned from DM' do
      let(:response) do
        double 'httparty_response',
               code: 200,
               to_s: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n<Success/>\n"
      end

      it 'does not log any errors and updates #exported_oa_status_to_activity_insight' do
        exporter_object = exporter.new([aif1])
        allow(HTTParty).to receive(:post).and_return response
        expect_any_instance_of(Logger).to receive(:info).with(/started at|ended at|Files not/).exactly(3).times
        expect_any_instance_of(Logger).not_to receive(:error)
        expect { exporter_object.export }.to change(pub1, :exported_oa_status_to_activity_insight).to true
      end
    end
  end
end
