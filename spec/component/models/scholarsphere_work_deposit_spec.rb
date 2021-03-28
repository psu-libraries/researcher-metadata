require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the scholarsphere_work_deposits table', type: :model do
  subject { ScholarsphereWorkDeposit.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:authorship_id).of_type(:integer) }
  it { is_expected.to have_db_column(:status).of_type(:string) }
  it { is_expected.to have_db_column(:error_message).of_type(:text) }
  it { is_expected.to have_db_column(:deposited_at).of_type(:datetime) }
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

  it { is_expected.to delegate_method(:publication).to(:authorship) }

  it { is_expected.to validate_inclusion_of(:status).in_array ['Pending', 'Success', 'Failed'] }

  describe '.statuses' do
    it "returns an array of the possible statuses for the deposit" do
      expect(ScholarsphereWorkDeposit.statuses).to eq ['Pending', 'Success', 'Failed']
    end
  end
end
