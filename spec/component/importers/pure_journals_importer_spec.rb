require 'component/component_spec_helper'
RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 1000000000

describe PureJournalsImporter do
  let(:importer) { PureJournalsImporter.new }
  let(:found_journal_1) { Journal.find_by(pure_uuid: 'b387416f-17e0-4ee3-a030-2f15b890380d') }
  let(:found_journal_2) { Journal.find_by(pure_uuid: '68edd4d0-f54f-423c-9548-f0b7032e5b50') }
  let!(:publisher) { create :publisher, pure_uuid: '435826f4-a25d-4005-b9da-47d3507834ff' }
  let(:http_response_1) { File.read(filename_1) }
  let(:http_response_2) { File.read(filename_2) }
  let(:http_error_response) { File.read(error_filename) }
  let(:filename_1) { Rails.root.join('spec', 'fixtures', 'pure_journals_1.json') }
  let(:filename_2) { Rails.root.join('spec', 'fixtures', 'pure_journals_2.json') }
  let(:error_filename) { Rails.root.join('spec', 'fixtures', 'pure_not_found_error.json') }

  before do
    allow(HTTParty).to receive(:get).with('https://pennstate.pure.elsevier.com/ws/api/520/journals?navigationLink=false&size=1&offset=0',
                                          headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_response_1

    allow(HTTParty).to receive(:get).with('https://pennstate.pure.elsevier.com/ws/api/520/journals?navigationLink=false&size=1000&offset=0',
                                          headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_response_2
  end

  describe '#call' do
    context 'when the API endpoint is found' do
      context 'when no journals already exist in the database' do
        it 'creates new journal records for every journal in the imported data' do
          expect { importer.call }.to change(Journal, :count).by 2

          expect(found_journal_1.title).to eq 'Tsitologiya'
          expect(found_journal_1.publisher).to eq publisher
          expect(found_journal_2.title).to eq 'Zuchtungskunde'
          expect(found_journal_2.publisher).to be_nil
        end
      end

      context 'when a journal matching the imported data already exists in the database' do
        let(:existing_publisher) { create :publisher }
        let!(:existing_journal) { create :journal,
                                         pure_uuid: 'b387416f-17e0-4ee3-a030-2f15b890380d',
                                         title: 'existing title',
                                         publisher: existing_publisher }

        it 'creates new journal records for every new journal in the imported data and updates existing publishers' do
          expect { importer.call }.to change(Journal, :count).by 1

          expect(existing_journal.reload.title).to eq 'Tsitologiya'
          expect(existing_journal.reload.publisher).to eq publisher
          expect(found_journal_2.title).to eq 'Zuchtungskunde'
          expect(found_journal_2.publisher).to be_nil
        end
      end

      context "when the imported data doesn't include publisher information" do
        let(:filename_2) { Rails.root.join('spec', 'fixtures', 'pure_journals_3.json') }

        context 'when no journals already exist in the database' do
          it 'creates new journal records for every journal in the imported data' do
            expect { importer.call }.to change(Journal, :count).by 2

            expect(found_journal_1.title).to eq 'Tsitologiya'
            expect(found_journal_1.publisher).to be_nil
            expect(found_journal_2.title).to eq 'Zuchtungskunde'
            expect(found_journal_2.publisher).to be_nil
          end
        end

        context 'when a journal matching the imported data already exists in the database' do
          let(:existing_publisher) { create :publisher }
          let!(:existing_journal) { create :journal,
                                           pure_uuid: 'b387416f-17e0-4ee3-a030-2f15b890380d',
                                           title: 'existing title',
                                           publisher: existing_publisher }

          it 'creates new journal records for every new journal in the imported data and updates existing publishers' do
            expect { importer.call }.to change(Journal, :count).by 1

            expect(existing_journal.reload.title).to eq 'Tsitologiya'
            expect(existing_journal.reload.publisher).to eq existing_publisher
            expect(found_journal_2.title).to eq 'Zuchtungskunde'
            expect(found_journal_2.publisher).to be_nil
          end
        end
      end
    end

    context 'when the API endpoint is not found' do
      before do
        allow(HTTParty).to receive(:get).with('https://pennstate.pure.elsevier.com/ws/api/520/journals?navigationLink=false&size=1&offset=0',
                                              headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_error_response

        allow(HTTParty).to receive(:get).with('https://pennstate.pure.elsevier.com/ws/api/520/journals?navigationLink=false&size=1000&offset=0',
                                              headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_error_response
      end

      it 'raises an error' do
        expect { importer.call }.to raise_error PureImporter::ServiceNotFound
      end
    end
  end
end
