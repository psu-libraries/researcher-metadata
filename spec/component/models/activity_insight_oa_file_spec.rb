# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

RSpec.describe ActivityInsightOAFile, type: :model do
  subject(:aif) { described_class.new }

  it { is_expected.to have_db_column(:location).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:version).of_type(:string) }
  it { is_expected.to have_db_column(:file_download_location).of_type(:string) }
  it { is_expected.to have_db_column(:downloaded).of_type(:boolean) }
  it { is_expected.to have_db_column(:publication_id).of_type(:integer) }
  it { is_expected.to have_db_column(:user_id).of_type(:integer) }

  it { is_expected.to have_db_foreign_key(:publication_id) }
  it { is_expected.to have_db_foreign_key(:user_id) }

  it { is_expected.to have_db_index :publication_id }
  it { is_expected.to have_db_index :user_id }

  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:publication).inverse_of(:activity_insight_oa_files) }
    it { is_expected.to belong_to(:user).required }
  end

  describe '#file_download_location' do
    it 'mounts an ActivityInsightFileUploader' do
      expect(subject.file_download_location).to be_a(ActivityInsightFileUploader)
    end
  end

  describe '#stored_file_path' do
    let(:uploader) { double 'uploader', file: file }
    let(:file) { double 'file', file: path }
    let(:path) { 'the/file/path' }

    context 'when stored file exists' do
      before { allow(ActivityInsightFileUploader).to receive(:new).and_return uploader }

      it 'returns the full path to the saved file' do
        expect(subject.stored_file_path).to eq 'the/file/path'
      end
    end

    context "when stored file doesn't exist" do
      it 'returns nil' do
        expect(subject.stored_file_path).to be_nil
      end
    end
  end

  describe 'scopes' do
    let!(:pub1) { create(:publication,
                         title: 'pub1')
    }
    let!(:pub2) { create(:publication,
                         title: 'pub2',
                         publication_type: 'Trade Journal Article')
    }
    let!(:pub3) { create(:publication,
                         title: 'pub3',
                         open_access_locations: [
                           build(:open_access_location, source: Source::OPEN_ACCESS_BUTTON, url: 'url', publication: nil)
                         ])
    }
    let(:uploader) { fixture_file_open('test_file.pdf') }
    let!(:file1) { create(:activity_insight_oa_file, publication: pub1) }
    let!(:file2) { create(:activity_insight_oa_file, publication: pub2) }
    let!(:file4) { create(:activity_insight_oa_file, publication: pub3) }
    let!(:file5) { create(:activity_insight_oa_file, publication: pub2, file_download_location: uploader) }
    let!(:file6) { create(:activity_insight_oa_file, publication: pub2, downloaded: true) }
    let!(:file7) { create(:activity_insight_oa_file, publication: pub2, location: nil) }

    describe '.ready_for_download' do
      it 'returns files that are ready to download from Activity Insight' do
        expect(described_class.ready_for_download).to match_array [file1]
      end
    end
  end

  describe '#download_filename' do
    before { aif.location = 'abc123/intellcont/test_publication.pdf' }

    it "returns the part of the file's location after the last forward slash" do
      expect(aif.download_filename).to eq 'test_publication.pdf'
    end
  end

  describe '#update_download_location' do
    let(:aif) { create(:activity_insight_oa_file, location: 'abc123/intellcont/test_publication.pdf') }

    it "updates the value in the file_download_location column to the part of the file's location after the last forward slash" do
      aif.update_download_location
      expect(aif.reload.file_download_location.file.filename).to eq 'test_publication.pdf'
    end
  end

  describe '#download_uri' do
    before { aif.location = 'abc123/intellcont/test_publication.pdf' }

    it "returns the full URI for the file in Activity Insight's AWS S3 bucket" do
      expect(aif.download_uri).to eq 'https://ai-s3-authorizer.k8s.libraries.psu.edu/api/v1/abc123/intellcont/test_publication.pdf'
    end
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:version).in_array(described_class::ALLOWED_VERSIONS).allow_nil }
  end

  describe '#version_status_display' do
    context 'when version is "unknown"' do
      let(:file) { create(:activity_insight_oa_file, version: 'unknown') }

      it 'returns "Unknown Version"' do
        expect(file.version_status_display).to eq 'Unknown Version'
      end
    end

    context 'when version is "acceptedVersion"' do
      let(:file) { create(:activity_insight_oa_file, version: 'acceptedVersion') }

      it 'returns "Accepted Manuscript"' do
        expect(file.version_status_display).to eq 'Accepted Manuscript'
      end
    end

    context 'when version is "publishedVersion"' do
      let(:file) { create(:activity_insight_oa_file, version: 'publishedVersion') }

      it 'returns "Final Published Version"' do
        expect(file.version_status_display).to eq 'Final Published Version'
      end
    end
  end

  describe '#download_location_value' do
    let!(:file) { create(:activity_insight_oa_file, file_download_location: fixture_file_open('test_file.pdf')) }

    it 'returns the value stored in the file_download_location column' do
      expect(file.download_location_value).to eq 'test_file.pdf'
    end
  end
end
