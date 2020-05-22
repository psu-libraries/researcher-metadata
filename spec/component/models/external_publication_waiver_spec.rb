require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the external_publication_waivers table', type: :model do
  subject { ExternalPublicationWaiver.new }

  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_title).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:reason_for_waiver).of_type(:text) }
  it { is_expected.to have_db_column(:abstract).of_type(:text) }
  it { is_expected.to have_db_column(:doi).of_type(:string) }
  it { is_expected.to have_db_column(:journal_title).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:publisher).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :user_id }

  it { is_expected.to have_db_foreign_key(:user_id) }
end

describe ExternalPublicationWaiver, type: :model do
  it_behaves_like "an application record"

  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:external_publication_waivers) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:publication_title) }
    it { is_expected.to validate_presence_of(:journal_title) }
    it { is_expected.to validate_presence_of(:doi) }
  end

  describe '#title' do
    let(:waiver) { ExternalPublicationWaiver.new(publication_title: "The Title") }
    it "returns the value for publication title" do
      expect(waiver.title).to eq "The Title"
    end
  end
end
