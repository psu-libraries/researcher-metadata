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

  describe '.statuses' do
    it "returns an array of the possible statuses for the deposit" do
      expect(ScholarsphereWorkDeposit.statuses).to eq ['Pending', 'Success', 'Failed']
    end
  end

  describe '#record_success' do
    let!(:dep) { create :scholarsphere_work_deposit, authorship: auth }
    let!(:auth) { create :authorship, publication: pub }
    let!(:pub) { create :publication }
    let(:now) { Time.new(2021, 3, 28, 22, 8, 0) }
    let!(:upload1) { create :scholarsphere_file_upload, work_deposit: dep }
    let!(:upload2) { create :scholarsphere_file_upload, work_deposit: dep }

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

    it "delete's all of the deposit's associated file uploads" do
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
end
