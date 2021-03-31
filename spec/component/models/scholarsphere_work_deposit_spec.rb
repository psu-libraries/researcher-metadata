require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the scholarsphere_work_deposits table', type: :model do
  subject { ScholarsphereWorkDeposit.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:authorship_id).of_type(:integer) }
  it { is_expected.to have_db_column(:status).of_type(:string) }
  it { is_expected.to have_db_column(:error_message).of_type(:text) }
  it { is_expected.to have_db_column(:deposited_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:title).of_type(:text) }
  it { is_expected.to have_db_column(:description).of_type(:text) }
  it { is_expected.to have_db_column(:published_date).of_type(:date) }
  it { is_expected.to have_db_column(:rights).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:authorship_id) }

  it { is_expected.to have_db_foreign_key(:authorship_id) }
end

describe ScholarsphereFileUpload, type: :model do
  subject(:upload) { ScholarsphereWorkDeposit.new }

  it_behaves_like "an application record"

  it { is_expected.to belong_to(:authorship) }
  it { is_expected.to have_many(:file_uploads).class_name(:ScholarsphereFileUpload).dependent(:destroy) }

  it { is_expected.to accept_nested_attributes_for(:file_uploads) }

  it { is_expected.to have_one(:publication).through(:authorship) }

  it { is_expected.to validate_inclusion_of(:status).in_array ['Pending', 'Success', 'Failed'] }
  it { is_expected.to validate_inclusion_of(:rights).in_array %w{
      https://creativecommons.org/licenses/by/4.0/
      https://creativecommons.org/licenses/by-sa/4.0/
      https://creativecommons.org/licenses/by-nc/4.0/
      https://creativecommons.org/licenses/by-nd/4.0/
      https://creativecommons.org/licenses/by-nc-nd/4.0/
      https://creativecommons.org/licenses/by-nc-sa/4.0/
      http://creativecommons.org/publicdomain/mark/1.0/
      http://creativecommons.org/publicdomain/zero/1.0/
      https://rightsstatements.org/page/InC/1.0/
      http://www.apache.org/licenses/LICENSE-2.0
      https://www.gnu.org/licenses/gpl.html
      https://opensource.org/licenses/MIT
      https://opensource.org/licenses/BSD-3-Clause
    }
  }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:published_date) }
  it { is_expected.to validate_presence_of(:rights) }

  describe "validating file upload association" do
    let(:dep) { build :scholarsphere_work_deposit, file_uploads: [], status: status}
    context "when the deposit's status is 'Pending'" do
      let(:status) { 'Pending' }
      it "validates that the deposit has at least one associated file upload" do
        expect(dep).not_to be_valid
        expect(dep.errors[:base]).to include I18n.t('models.scholarsphere_work_deposit.validation_errors.file_upload_presence')
      end
    end

    context "when the deposit's status is not 'Pending'" do
      let(:status) { 'Success' }
      it "does not validate that the deposit has at least one associated file upload" do
        expect(dep).to be_valid
      end
    end
  end

  describe "instantiating a deposit" do
    context "when the deposit is a new record" do
      it "sets the deposit's status to 'Pending'" do
        expect(ScholarsphereWorkDeposit.new.status).to eq 'Pending'
      end
    end

    context "when the deposit is persisted" do
      let!(:dep) { create :scholarsphere_work_deposit, status: 'Success' }
      it "does not set the deposit's status to 'Pending'" do
        expect(ScholarsphereWorkDeposit.find(dep.id).status).to eq 'Success'
      end
    end
  end

  describe '.statuses' do
    it "returns an array of the possible statuses for the deposit" do
      expect(ScholarsphereWorkDeposit.statuses).to eq ['Pending', 'Success', 'Failed']
    end
  end

  describe '.rights' do
    it "returns an array of the possible rights statements for the deposit" do
      expect(ScholarsphereWorkDeposit.rights).to eq %w{
        https://creativecommons.org/licenses/by/4.0/
        https://creativecommons.org/licenses/by-sa/4.0/
        https://creativecommons.org/licenses/by-nc/4.0/
        https://creativecommons.org/licenses/by-nd/4.0/
        https://creativecommons.org/licenses/by-nc-nd/4.0/
        https://creativecommons.org/licenses/by-nc-sa/4.0/
        http://creativecommons.org/publicdomain/mark/1.0/
        http://creativecommons.org/publicdomain/zero/1.0/
        https://rightsstatements.org/page/InC/1.0/
        http://www.apache.org/licenses/LICENSE-2.0
        https://www.gnu.org/licenses/gpl.html
        https://opensource.org/licenses/MIT
        https://opensource.org/licenses/BSD-3-Clause
      }
    end
  end

  describe '.rights_options' do
    it "returns an array of the possible rights statements along with descriptions of each" do
      expect(ScholarsphereWorkDeposit.rights_options).to eq [
        ['Attribution 4.0 International (CC BY 4.0)', 'https://creativecommons.org/licenses/by/4.0/'],
        ['Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)', 'https://creativecommons.org/licenses/by-sa/4.0/'],
        ['Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)', 'https://creativecommons.org/licenses/by-nc/4.0/'],
        ['Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)', 'https://creativecommons.org/licenses/by-nd/4.0/'],
        ['Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)', 'https://creativecommons.org/licenses/by-nc-nd/4.0/'],
        ['Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)', 'https://creativecommons.org/licenses/by-nc-sa/4.0/'],
        ['Public Domain Mark 1.0', 'http://creativecommons.org/publicdomain/mark/1.0/'],
        ['CC0 1.0 Universal', 'http://creativecommons.org/publicdomain/zero/1.0/'],
        ['All rights reserved', 'https://rightsstatements.org/page/InC/1.0/'],
        ['Apache 2.0', 'http://www.apache.org/licenses/LICENSE-2.0'],
        ['GNU General Public License (GPLv3)', 'https://www.gnu.org/licenses/gpl.html'],
        ['MIT License', 'https://opensource.org/licenses/MIT'],
        ['BSD 3-Clause License', 'https://opensource.org/licenses/BSD-3-Clause']
      ]
    end
  end

  describe '.new_from_authorship' do
    let(:auth) { create :authorship, publication: pub }
    let(:pub) { create :publication,
                       title: 'a test title',
                       abstract: 'a test description',
                       published_on: Date.new(2021, 3, 30) }

    it "returns a new instance of a deposit populated with data from the given authorship" do
      dep = ScholarsphereWorkDeposit.new_from_authorship(auth)

      expect(dep.authorship).to eq auth
      expect(dep.title).to eq 'a test title'
      expect(dep.description).to eq 'a test description'
      expect(dep.published_date).to eq Date.new(2021, 3, 30)
    end
  end

  describe '#record_success' do
    let!(:dep) { create :scholarsphere_work_deposit, file_uploads: [upload1, upload2], authorship: auth }
    let!(:auth) { create :authorship, publication: pub }
    let!(:pub) { create :publication }
    let(:now) { Time.new(2021, 3, 28, 22, 8, 0) }
    let(:upload1) { create :scholarsphere_file_upload }
    let(:upload2) { create :scholarsphere_file_upload }

    before { allow(Time).to receive(:current).and_return now }

    it "updates the deposit's publication with the given URL" do
      dep.record_success('an_open_access_url')
      expect(pub.reload.scholarsphere_open_access_url).to eq 'an_open_access_url'
    end

    it "sets the deposit's status to 'Success'" do
      dep.record_success('an_open_access_url')
      expect(dep.reload.status).to eq 'Success'
    end

    it "sets the deposit's deposit timestamp" do
      dep.record_success('an_open_access_url')
      expect(dep.reload.deposited_at).to eq now
    end

    it "deletes all of the deposit's associated file uploads" do
      dep.record_success('an_open_access_url')
      expect { upload1.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { upload2.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    context "when an error is raised when updating the publication" do
      before do
        allow_any_instance_of(Publication).to receive(:update!).and_raise(RuntimeError)
      end

      it "does not set the deposit's status to 'Success'" do
        suppress(RuntimeError) do
          dep.record_success('an_open_access_url')
        end
        expect(dep.reload.status).not_to eq 'Success'
      end

      it "does not set the deposit's deposit timestamp" do
        suppress(RuntimeError) do
          dep.record_success('an_open_access_url')
        end
        expect(dep.reload.deposited_at).not_to eq now
      end

      it "does not delete all of the deposit's associated file uploads" do
        suppress(RuntimeError) do
          dep.record_success('an_open_access_url')
        end
        expect(upload1.reload).to eq upload1
        expect(upload2.reload).to eq upload2
      end
    end
  end

  describe '#metadata' do
    let!(:auth) { create :authorship, publication: pub }
    let!(:pub) { create :publication }
    let!(:cn1) { create :contributor_name,
                        publication: pub,
                        first_name: 'Test',
                        last_name: 'Author',
                        position: 2 }
    let!(:cn2) { create :contributor_name,
                        publication: pub,
                        first_name: 'Another',
                        last_name: 'Contributor',
                        position: 3 }
    let!(:cn3) { create :contributor_name,
                        publication: pub,
                        first_name: 'A.',
                        last_name: 'Researcher',
                        position: 1,
                        user: user }
    let!(:user) { create :user, webaccess_id: 'abc123', orcid_identifier: 'orcid-id-456'}
    let(:dep) { 
      ScholarsphereWorkDeposit.new(
        title: 'test title',
        description: 'test description',
        published_date: Date.new(2021, 3, 30),
        rights: 'https://creativecommons.org/licenses/by/4.0/',
        authorship: auth
      )
    }

    it "returns a hash of the metadata needed to create a ScholarSphere work" do
      expect(dep.metadata).to eq ({
        title: 'test title',
        description: 'test description',
        published_date: Date.new(2021, 3, 30),
        work_type: 'article',
        visibility: 'open',
        rights: 'https://creativecommons.org/licenses/by/4.0/',
        creators: [
          {psu_id: 'abc123', orcid: 'orcid-id-456', display_name: 'A. Researcher'},
          {display_name: 'Test Author'},
          {display_name: 'Another Contributor'}
        ]
      })
    end
  end
end
