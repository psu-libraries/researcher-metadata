# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'
RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = nil
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
  it { is_expected.to have_db_column(:permissions_last_checked_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:license).of_type(:string) }
  it { is_expected.to have_db_column(:embargo_date).of_type(:date) }
  it { is_expected.to have_db_column(:set_statement).of_type(:text) }
  it { is_expected.to have_db_column(:checked_for_set_statement).of_type(:boolean) }
  it { is_expected.to have_db_column(:checked_for_embargo_date).of_type(:boolean) }

  it { is_expected.to have_db_foreign_key(:publication_id) }
  it { is_expected.to have_db_foreign_key(:user_id) }

  it { is_expected.to have_db_index :publication_id }
  it { is_expected.to have_db_index :user_id }

  it_behaves_like 'an application record'

  it { is_expected.to delegate_method(:doi_url_path).to(:publication) }
  it { is_expected.to delegate_method(:doi).to(:publication) }

  describe 'associations' do
    it { is_expected.to belong_to(:publication).inverse_of(:activity_insight_oa_files) }
    it { is_expected.to belong_to(:user).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:intellcont_id) }
    it { is_expected.to validate_presence_of(:post_file_id) }

    it { expect(subject).to validate_inclusion_of(:version).in_array(
      %w{
        acceptedVersion
        publishedVersion
        unknown
        notArticleFile
      }
    ).allow_nil }

    it { expect(subject).to validate_inclusion_of(:license).in_array(%w{
                                                                       https://creativecommons.org/licenses/by/4.0/
                                                                       https://creativecommons.org/licenses/by-sa/4.0/
                                                                       https://creativecommons.org/licenses/by-nc/4.0/
                                                                       https://creativecommons.org/licenses/by-nd/4.0/
                                                                       https://creativecommons.org/licenses/by-nc-nd/4.0/
                                                                       https://creativecommons.org/licenses/by-nc-sa/4.0/
                                                                       http://creativecommons.org/publicdomain/mark/1.0/
                                                                       http://creativecommons.org/publicdomain/zero/1.0/
                                                                       https://rightsstatements.org/page/InC/1.0/
                                                                     }).allow_blank
    }
  end

  describe '.export_statuses' do
    it 'returns the list of valid values for activity insight export status' do
      expect(described_class.export_statuses).to eq [
        'Cannot Deposit',
        'Already Openly Available',
        'Deposited to ScholarSphere',
        'In Progress',
        nil
      ]
    end
  end

  describe 'destroy' do
    let!(:aif1) { create(:activity_insight_oa_file,
                         file_download_location: fixture_file_open('test_file.pdf')) }
    let!(:file_download_directory) { aif1.file_download_location.model_object_dir }

    it 'removes the file download directory' do
      expect(File.exist?(file_download_directory)).to be true
      aif1.destroy
      expect(File.exist?(file_download_directory)).to be false
    end
  end

  describe '.licenses' do
    it 'returns an array of the possible licenses for a file' do
      expect(described_class.licenses).to eq %w{
        https://creativecommons.org/licenses/by/4.0/
        https://creativecommons.org/licenses/by-sa/4.0/
        https://creativecommons.org/licenses/by-nc/4.0/
        https://creativecommons.org/licenses/by-nd/4.0/
        https://creativecommons.org/licenses/by-nc-nd/4.0/
        https://creativecommons.org/licenses/by-nc-sa/4.0/
        http://creativecommons.org/publicdomain/mark/1.0/
        http://creativecommons.org/publicdomain/zero/1.0/
        https://rightsstatements.org/page/InC/1.0/
      }
    end
  end

  describe '.license_options' do
    it 'returns an array of the possible licenses for a file along with descriptions of each' do
      expect(described_class.license_options).to eq [
        ['Attribution 4.0 International (CC BY 4.0)', 'https://creativecommons.org/licenses/by/4.0/'],
        ['Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)', 'https://creativecommons.org/licenses/by-sa/4.0/'],
        ['Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)', 'https://creativecommons.org/licenses/by-nc/4.0/'],
        ['Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)', 'https://creativecommons.org/licenses/by-nd/4.0/'],
        ['Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)', 'https://creativecommons.org/licenses/by-nc-nd/4.0/'],
        ['Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)', 'https://creativecommons.org/licenses/by-nc-sa/4.0/'],
        ['Public Domain Mark 1.0', 'http://creativecommons.org/publicdomain/mark/1.0/'],
        ['CC0 1.0 Universal', 'http://creativecommons.org/publicdomain/zero/1.0/'],
        ['All rights reserved', 'https://rightsstatements.org/page/InC/1.0/']
      ]
    end
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
                         open_access_status: nil,
                         title: 'pub1')
    }
    let!(:pub2) { create(:publication,
                         title: 'pub2',
                         open_access_status: 'closed',
                         publication_type: 'Trade Journal Article')
    }
    let!(:pub3) { create(:publication,
                         title: 'pub3',
                         open_access_locations: [
                           build(:open_access_location, source: Source::OPEN_ACCESS_BUTTON, url: 'url1', publication: nil),
                           build(:open_access_location, source: Source::OPEN_ACCESS_BUTTON, url: 'url2', publication: nil)
                         ],
                         open_access_status: 'green')
    }
    let!(:pub4) { create(:publication,
                         title: 'pub4',
                         open_access_status: 'gold')
    }
    let!(:pub5) { create(:publication,
                         title: 'pub5',
                         open_access_status: 'hybrid',
                         open_access_locations: [
                           build(:open_access_location, source: Source::UNPAYWALL, url: 'url1', publication: nil),
                           build(:open_access_location, source: Source::UNPAYWALL, url: 'url2', publication: nil)
                         ])
    }
    let!(:pub6) { create(:publication,
                         title: 'pub6',
                         open_access_locations: [
                           build(:open_access_location, source: Source::SCHOLARSPHERE, url: 'url', publication: nil)
                         ],
                         open_access_status: 'green')
    }
    let!(:pub7) { create(:publication,
                         title: 'pub7',
                         open_access_locations: [
                           build(:open_access_location, source: Source::DICKINSON_INSIGHT, url: 'url', publication: nil)
                         ])
    }
    let(:uploader) { fixture_file_open('test_file.pdf') }
    let!(:member_user) { create(:user, :with_psu_member_affiliation) }
    let!(:file1) { create(:activity_insight_oa_file, publication: pub1) }
    let!(:file1b) { create(:activity_insight_oa_file, publication: pub1, user: member_user) }
    let!(:file2) { create(:activity_insight_oa_file, publication: pub2) }
    let!(:file3) { create(:activity_insight_oa_file, publication: pub3, file_download_location: uploader) }
    let!(:file4) { create(:activity_insight_oa_file, publication: pub3, downloaded: true) }
    let!(:file5) { create(:activity_insight_oa_file, publication: pub3, location: nil) }
    let!(:file6) { create(:activity_insight_oa_file, publication: pub4) }
    let!(:file7) { create(:activity_insight_oa_file, publication: pub5, downloaded: true) }
    let!(:file8) { create(:activity_insight_oa_file, publication: pub4, downloaded: true, exported_oa_status_to_activity_insight: true) }
    let!(:file9) { create(:activity_insight_oa_file, publication: pub6, downloaded: true) }
    let!(:file10) { create(:activity_insight_oa_file, publication: pub5) }
    let!(:file11) { create(:activity_insight_oa_file, publication: pub6) }
    let!(:file12) {
      create(
        :activity_insight_oa_file,
        version: 'acceptedVersion',
        location: nil
      )
    }
    let!(:file13) {
      create(
        :activity_insight_oa_file,
        version: 'publishedVersion',
        location: nil
      )
    }
    let!(:file14) {
      create(
        :activity_insight_oa_file,
        version: 'unknown',
        location: nil
      )
    }
    let!(:file15) {
      create(
        :activity_insight_oa_file,
        version: 'acceptedVersion',
        location: nil,
        permissions_last_checked_at: Time.now
      )
    }
    let!(:file16) {
      create(
        :activity_insight_oa_file,
        version: 'publishedVersion',
        location: nil,
        permissions_last_checked_at: Time.now
      )
    }
    let!(:file17) {
      create(
        :activity_insight_oa_file,
        publication: pub1,
        file_download_location:
        uploader,
        downloaded: true
      )
    }
    let!(:file18) {
      create(
        :activity_insight_oa_file,
        publication: pub1,
        file_download_location: uploader,
        version_checked: true
      )
    }
    let!(:file19) {
      create(
        :activity_insight_oa_file,
        publication: pub1,
        file_download_location: uploader,
        version: 'unknown'
      )
    }
    let!(:file20) { create(:activity_insight_oa_file, publication: pub7) }

    describe '.subject_to_ai_oa_workflow' do
      it 'returns files that have an associated publication that is subject to the activity insight oa workflow' do
        expect(described_class.subject_to_ai_oa_workflow).to contain_exactly(file1, file3, file4, file17, file18, file19)
      end
    end

    describe '.ready_for_download' do
      it 'returns files that are ready to download from Activity Insight' do
        expect(described_class.ready_for_download).to contain_exactly(file1)
      end
    end

    describe '.needs_version_check' do
      it 'returns files that are ready to have their versions automatically determined' do
        expect(described_class.needs_version_check).to contain_exactly(file17)
      end
    end

    describe '.send_oa_status_to_activity_insight' do
      it 'returns files that have not yet been exported to activity insight & whose publication has a gold or hybrid oa status' do
        expect(described_class.send_oa_status_to_activity_insight).to contain_exactly(file6, file7, file9, file10, file11, file20)
      end
    end

    describe '.needs_permissions_check' do
      it 'returns files that have a known version but have not had their permissions checked yet' do
        expect(described_class.needs_permissions_check).to contain_exactly(file12, file13)
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

    context 'when version is "notArticleFile"' do
      let(:file) { create(:activity_insight_oa_file, version: 'notArticleFile') }

      it 'returns "Not Article File"' do
        expect(file.version_status_display).to eq 'Not Article File'
      end
    end
  end

  describe '#download_location_value' do
    let!(:file) { create(:activity_insight_oa_file, file_download_location: fixture_file_open('test_file.pdf')) }

    it 'returns the value stored in the file_download_location column' do
      expect(file.download_location_value).to eq 'test_file.pdf'
    end
  end

  describe '#journal' do
    let(:file) { create(:activity_insight_oa_file, publication: pub) }
    let(:pub) { create(:publication) }
    let(:policy) { instance_double PreferredJournalInfoPolicy, journal_title: 'A Journal' }

    before { allow(PreferredJournalInfoPolicy).to receive(:new).with(pub).and_return policy }

    it "delegates to the associatied publication's preferred journal title" do
      expect(file.journal).to eq 'A Journal'
    end
  end
end
