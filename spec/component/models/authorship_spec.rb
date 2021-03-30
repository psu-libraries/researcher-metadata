require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the authorships table', type: :model do
  subject { Authorship.new }

  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:author_number).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:visible_in_profile).of_type(:boolean).with_options(default: true) }
  it { is_expected.to have_db_column(:position_in_profile).of_type(:integer) }
  it { is_expected.to have_db_column(:confirmed).of_type(:boolean).with_options(default: true) }
  it { is_expected.to have_db_column(:scholarsphere_uploaded_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:role).of_type(:string) }
  it { is_expected.to have_db_column(:open_access_notification_sent_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:orcid_resource_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:updated_by_owner_at).of_type(:datetime) }

  it { is_expected.to have_db_index :user_id }
  it { is_expected.to have_db_index :publication_id }

  it { is_expected.to have_db_foreign_key(:user_id) }
  it { is_expected.to have_db_foreign_key(:publication_id) }
end

describe Authorship, type: :model do
  it_behaves_like "an application record"

  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:authorships) }
    it { is_expected.to belong_to(:publication).inverse_of(:authorships) }
    it { is_expected.to have_one(:waiver).class_name(:InternalPublicationWaiver).inverse_of(:authorship) }
    it { is_expected.to have_one(:scholarsphere_work_deposit) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:publication_id) }
    it { is_expected.to validate_presence_of(:author_number) }

    context "given otherwise valid data" do
      subject { Authorship.new(user: create(:user), publication: create(:publication)) }
      it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:publication_id) }
    end
  end

  it { is_expected.to delegate_method(:title).to(:publication) }
  it { is_expected.to delegate_method(:abstract).to(:publication) }
  it { is_expected.to delegate_method(:doi).to(:publication) }
  it { is_expected.to delegate_method(:published_by).to(:publication) }
  it { is_expected.to delegate_method(:year).to(:publication) }
  it { is_expected.to delegate_method(:preferred_open_access_url).to(:publication) }
  it { is_expected.to delegate_method(:scholarsphere_upload_pending?).to(:publication) }
  it { is_expected.to delegate_method(:open_access_waived?).to(:publication) }
  it { is_expected.to delegate_method(:no_open_access_information?).to(:publication) }
  it { is_expected.to delegate_method(:published_on).to(:publication) }
  it { is_expected.to delegate_method(:user_webaccess_id).to(:user).as(:webaccess_id) }

  it { is_expected.to accept_nested_attributes_for(:waiver) }

  describe "#description" do
    let(:u) { create :user, first_name: 'Bob', last_name: 'Testerson' }
    let(:p) { create :publication, title: 'Example Pub' }
    let(:a) { create :authorship, user: u, publication: p }
    it "returns a string describing the record" do
      expect(a.description).to eq "##{a.id} (Bob Testerson - Example Pub)"
    end
  end

  describe '#record_open_access_notification' do
    let(:a) { create :authorship }
    let(:now) { Time.new(2020, 6, 12, 15, 21, 0) }
    before { allow(Time).to receive(:current).and_return(now) }

    it "saves the current time in the open access notification timestamp field" do
      a.record_open_access_notification
      expect(a.reload.open_access_notification_sent_at).to eq now
    end
  end

  describe '#updated_by_owner' do
    let(:a) { Authorship.new(updated_by_owner_at: timestamp) }

    context "when the authorship has a value for updated_by_owner_at" do
      let(:timestamp) { Time.new(2000, 1, 1, 0, 0, 0) }
      it "returns a value of updated_by_owner_at that can be compared to a null time" do
        expect(a.updated_by_owner).to eq timestamp
        expect(a.updated_by_owner > NullTime.new).to eq true
      end
    end

    context "when the authorship does not have a value for updated_by_owner_at" do
      let(:timestamp) { nil }
      it "returns a null time" do
        expect(a.updated_by_owner).to be_a NullTime
      end
    end
  end
end
