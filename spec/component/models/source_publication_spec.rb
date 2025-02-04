# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the source_publications table', type: :model do
  subject { SourcePublication.new }

  it { is_expected.to have_db_column(:source_identifier).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:status).of_type(:string) }
  it { is_expected.to have_db_column(:import_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:import_id) }
  it { is_expected.to have_db_foreign_key(:import_id) }
end

describe SourcePublication, type: :model do
  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:import) }
  end

  describe '.find_in_latest_pure_list' do
    let!(:pub) { instance_double(Publication, pure_imports: pure_pub_imports) }
    let(:latest_pure_import) { nil }
    let(:pure_pub_imports) { [] }

    before { allow(Import).to receive(:latest_completed_from_pure).and_return latest_pure_import }

    context 'when there are no completed Pure imports' do
      it 'raises an error' do
        expect { described_class.find_in_latest_pure_list(pub) }.to raise_error SourcePublication::NoCompletedPureImports
      end
    end

    context 'when there are complete records of Pure imports' do
      let!(:latest_pure_import) { create(:import) }

      context 'when the given publication was not imported from Pure' do
        it 'raises an error' do
          expect { described_class.find_in_latest_pure_list(pub) }.to raise_error ArgumentError
        end
      end

      context 'when the given publication was imported from Pure' do
        let(:pure_pub_imports) { [ppi] }
        let(:ppi) { create(:publication_import, source_identifier: 'abc123') }

        context 'when the given publication has a publication import record that is still present in Pure' do
          let!(:sp) { create(:source_publication, import: latest_pure_import, source_identifier: 'abc123') }

          it 'returns the matching source publication record' do
            expect(described_class.find_in_latest_pure_list(pub)).to eq sp
          end

          context 'when the given publication has another publication import record that is not still present in Pure' do
            let(:pure_pub_imports) { [ppi2, ppi] }
            let(:ppi2) { create(:publication_import, source_identifier: 'def456') }

            it 'returns the matching source publication record' do
              expect(described_class.find_in_latest_pure_list(pub)).to eq sp
            end
          end
        end

        context 'when the given publication only has a publication import record that is not still present in Pure' do
          it 'returns nil' do
            expect(described_class.find_in_latest_pure_list(pub)).to be_nil
          end
        end
      end
    end
  end
end
