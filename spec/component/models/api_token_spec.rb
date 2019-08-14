require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the api_tokens table', type: :model do
  subject { APIToken.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:token).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:app_name).of_type(:string) }
  it { is_expected.to have_db_column(:admin_email).of_type(:string) }
  it { is_expected.to have_db_column(:total_requests).of_type(:integer).with_options(default: 0) }
  it { is_expected.to have_db_column(:last_used_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:token).unique(true) }
end

describe APIToken, type: :model do
  it_behaves_like "an application record"

  it { is_expected.to have_many(:organization_api_permissions).inverse_of(:api_token) }
  it { is_expected.to have_many(:organizations).through(:organization_api_permissions) }

  describe "creating a new token" do
    let(:new_token) { APIToken.new }

    it "sets a value for the token that is 64 characters long" do
      new_token.save!
      expect(new_token.token.length).to eq 96
    end
  end

  describe "deleting a token" do
    let(:token) { create :api_token }
    let!(:permission) { create :organization_api_permission, api_token: token }
    it "also deletes any associated organization API permissions" do
      token.destroy
      expect { permission.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '#increment_request_count' do
    let(:token) { create :api_token,
                         total_requests: 2,
                         last_used_at: Time.zone.local(2000, 1, 1, 8, 0, 0) }

    before do
      allow(Time).to receive(:current).and_return(Time.zone.local(2017, 11, 3, 9, 45, 0))
    end
    it "increases the saved number of total requests for the token by 1" do
      token.increment_request_count
      expect(token.reload.total_requests).to eq 3
    end

    it "updates the last_used_at timestamp on the token" do
      token.increment_request_count
      expect(token.reload.last_used_at).to eq Time.zone.local(2017, 11, 3, 9, 45, 0)
    end
  end
end
