# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

RSpec.describe ActivityInsightOAFile, type: :model do
  subject { described_class.new }

  it { is_expected.to have_db_column(:location).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:version).of_type(:string) }
  it { is_expected.to have_db_column(:version_checked).of_type(:boolean) }
  it { is_expected.to have_db_column(:file).of_type(:string) }
  it { is_expected.to have_db_column(:downloaded).of_type(:boolean) }

  it { is_expected.to have_db_foreign_key(:publication_id) }
  it { is_expected.to have_db_index :publication_id }

  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:publication).inverse_of(:activity_insight_oa_files) }
  end

  describe '#file' do
    it 'mounts an ActivityInsightFileUploader' do
      expect(subject.file).to be_a(ActivityInsightFileUploader)
    end
  end

  describe '#stored_file_path' do
    let(:uploader) { double 'uploader', file: file }
    let(:file) { double 'file', file: path }
    let(:path) { 'the/file/path' }

    before { allow(ActivityInsightFileUploader).to receive(:new).and_return uploader }

    it 'returns the full path to the saved file' do
      expect(subject.stored_file_path).to eq 'the/file/path'
    end
  end

  describe 'scopes' do
    let!(:pub1) { create(:publication,
                         title: 'pub1',
                         licence: nil,
                         doi_verified: true)
    }
    let!(:pub2) { create(:publication,
                         title: 'pub2',
                         licence: 'licence',
                         publication_type: 'Academic Journal Article')
    }
    let!(:pub3) { create(:publication,
                         title: 'pub3',
                         doi_verified: nil)
    }
    let!(:pub4) { create(:publication,
      title: 'pub4',
      licence: 'licence',
      publication_type: 'Trade Journal Article')
}
#add publication & file with open access location
    let!(:file1) { create(:activity_insight_oa_file, publication: pub1) }
    let!(:file2) { create(:activity_insight_oa_file, publication: pub2) }
    let!(:file3) { create(:activity_insight_oa_file, publication: pub1, version: 'acceptedVersion') }
    let!(:file4) { create(:activity_insight_oa_file, publication: pub1, version: 'publishedVersion') }
    let!(:file5) { create(:activity_insight_oa_file, publication: pub1, version: 'unknown') }
    let!(:file6) { create(:activity_insight_oa_file, publication: pub1, version: 'acceptedVersion', version_checked: true) }
    let!(:file7) { create(:activity_insight_oa_file, publication: pub3) }
    let!(:file8) { create(:activity_insight_oa_file, publication: pub4) }

    describe '.pub_without_permissions' do
      it 'returns files where the publication does not have permissions data' do
        expect(described_class.pub_without_permissions).to match_array [file1, file3, file4, file5, file6]
      end
    end

    describe '.needs_permissions_check' do
      it 'returns files that have not been checked that are accepted or published version' do
        expect(described_class.needs_permissions_check).to match_array [file3, file4]
      end
    end

    describe '.ready_for_download' do
      it 'returns files that are ready to download from Activity Insight' do
        expect(described_class.ready_for_download).to match_array [file2]
      end
    end
  end
end
