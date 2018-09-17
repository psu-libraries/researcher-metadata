require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the etds table', type: :model do
  subject { ETD.new }

  it { is_expected.to have_db_column(:title).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:author_first_name).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:author_middle_name).of_type(:string) }
  it { is_expected.to have_db_column(:author_last_name).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:webaccess_id).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:year).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:url).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:submission_type).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:external_identifier).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:access_level).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_by_user_at).of_type(:datetime) }

  it { is_expected.to have_db_index(:webaccess_id).unique(true) }
  it { is_expected.to have_db_index(:external_identifier).unique(true) }
end

describe ETD, type: :model do
  it_behaves_like "an application record"

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:author_first_name) }
    it { is_expected.to validate_presence_of(:author_last_name) }
    it { is_expected.to validate_presence_of(:webaccess_id) }
    it { is_expected.to validate_presence_of(:year) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:submission_type) }
    it { is_expected.to validate_presence_of(:external_identifier) }
    it { is_expected.to validate_presence_of(:access_level) }
    it { is_expected.to validate_inclusion_of(:submission_type).in_array(ETD.submission_types) }

    context "given an otherwise valid record" do
      subject {
        ETD.new(
          title: 'bucks dissertation',
          webaccess_id: 'abc123',
          external_identifier: 'def123',
          author_first_name: 'buck',
          author_last_name: 'murphy',
          year: 2018,
          url: 'https://etda.libraries.psu.edu/catalog/7332',
          submission_type: 'Dissertation',
          access_level: 'Open Access'
        )
      }
      it { is_expected.to validate_uniqueness_of(:webaccess_id).case_insensitive }
      it { is_expected.to validate_uniqueness_of(:external_identifier) }
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:committee_memberships).inverse_of(:etd) }
    it { is_expected.to have_many(:users).through(:committee_memberships) }
  end

  it { is_expected.to accept_nested_attributes_for(:committee_memberships).allow_destroy(true) }

  describe "deleting a etd with committee_memberships" do
    let(:etd) { create :etd }
    let!(:cm) { create :committee_membership, etd: etd}
    it "also deletes the etd's committee_memberships" do
      etd.destroy
      expect { cm.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '.submission_types' do
    it "returns the list of valid etd sbmission types" do
      expect(ETD.submission_types).to eq ["Dissertation", "Master Thesis"]
    end
  end
end
