require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the api_tokens table', type: :model do
  subject { APIToken.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:token).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:app_name).of_type(:string) }
  it { is_expected.to have_db_column(:admin_email).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:token).unique(true) }
end

describe APIToken, type: :model do
  it_behaves_like "an application record"

  describe "creating a new token" do
    let(:new_token) { APIToken.new }

    it "sets a value for the token that is 64 characters long" do
      new_token.save!
      expect(new_token.token.length).to eq 96
    end
  end
end
