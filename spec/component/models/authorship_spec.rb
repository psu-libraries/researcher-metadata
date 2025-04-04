# frozen_string_literal: true

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
  it { is_expected.to have_db_column(:role).of_type(:string) }
  it { is_expected.to have_db_column(:open_access_notification_sent_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:orcid_resource_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:updated_by_owner_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:claimed_by_user).of_type(:boolean).with_options(default: false) }

  it { is_expected.to have_db_index :user_id }
  it { is_expected.to have_db_index :publication_id }

  it { is_expected.to have_db_foreign_key(:user_id) }
  it { is_expected.to have_db_foreign_key(:publication_id) }
end

describe Authorship, type: :model do
  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:authorships) }
    it { is_expected.to belong_to(:publication).inverse_of(:authorships) }
    it { is_expected.to have_one(:waiver).class_name(:InternalPublicationWaiver).inverse_of(:authorship) }
    it { is_expected.to have_many(:scholarsphere_work_deposits) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:publication_id) }
    it { is_expected.to validate_presence_of(:author_number) }

    context 'given otherwise valid data' do
      subject { described_class.new(user: create(:user), publication: create(:publication)) }

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
  it { is_expected.to delegate_method(:scholarsphere_upload_failed?).to(:publication) }
  it { is_expected.to delegate_method(:open_access_waived?).to(:publication) }
  it { is_expected.to delegate_method(:no_open_access_information?).to(:publication) }
  it { is_expected.to delegate_method(:published_on).to(:publication) }
  it { is_expected.to delegate_method(:secondary_title).to(:publication) }
  it { is_expected.to delegate_method(:preferred_publisher_name).to(:publication) }
  it { is_expected.to delegate_method(:preferred_journal_title).to(:publication) }
  it { is_expected.to delegate_method(:published?).to(:publication) }
  it { is_expected.to delegate_method(:user_webaccess_id).to(:user).as(:webaccess_id) }
  it { is_expected.to delegate_method(:user_name).to(:user).as(:name) }

  it { is_expected.to accept_nested_attributes_for(:waiver) }

  describe '.unclaimable' do
    let!(:auth1) { create(:authorship, claimed_by_user: false, confirmed: false) }
    let!(:auth2) { create(:authorship, claimed_by_user: true, confirmed: false) }
    let!(:auth3) { create(:authorship, claimed_by_user: false, confirmed: true) }
    let!(:auth4) { create(:authorship, claimed_by_user: true, confirmed: true) }

    it 'only returns authorships that are either confirmed or already claimed by a user' do
      expect(described_class.unclaimable).to contain_exactly(auth2, auth3, auth4)
    end
  end

  describe '.confirmed' do
    let!(:auth1) { create(:authorship, confirmed: false) }
    let!(:auth2) { create(:authorship, confirmed: true) }

    it 'only returns authorships that are confirmed' do
      expect(described_class.confirmed).to eq [auth2]
    end
  end

  describe '.claimed_and_unconfirmed' do
    let!(:auth1) { create(:authorship, claimed_by_user: false, confirmed: false) }
    let!(:auth2) { create(:authorship, claimed_by_user: true, confirmed: false) }
    let!(:auth3) { create(:authorship, claimed_by_user: false, confirmed: true) }
    let!(:auth4) { create(:authorship, claimed_by_user: true, confirmed: true) }

    it 'only returns authorships that are both claimed by a user and unconfirmed' do
      expect(described_class.claimed_and_unconfirmed).to contain_exactly(auth2)
    end
  end

  describe '#description' do
    let(:u) { create(:user, first_name: 'Bob', last_name: 'Testerson') }
    let(:p) { create(:publication, title: 'Example Pub') }

    context 'when the authorship is not persisted' do
      let(:a) { described_class.new }

      it 'returns nil' do
        expect(a.description).to be_nil
      end
    end

    context 'when the authorship is persisted' do
      let(:a) { create(:authorship, user: u, publication: p) }

      it 'returns a string describing the record' do
        expect(a.description).to eq "##{a.id} (Bob Testerson - Example Pub)"
      end
    end
  end

  describe '#record_open_access_notification' do
    let(:a) { create(:authorship) }
    let(:now) { Time.new(2020, 6, 12, 15, 21, 0) }

    before { allow(Time).to receive(:current).and_return(now) }

    it 'saves the current time in the open access notification timestamp field' do
      a.record_open_access_notification
      expect(a.reload.open_access_notification_sent_at).to eq now
    end
  end

  describe '#updated_by_owner' do
    let(:a) { described_class.new(updated_by_owner_at: timestamp) }

    context 'when the authorship has a value for updated_by_owner_at' do
      let(:timestamp) { Time.new(2000, 1, 1, 0, 0, 0) }

      it 'returns a value of updated_by_owner_at that can be compared to a null time' do
        expect(a.updated_by_owner).to eq timestamp
        expect(a.updated_by_owner > NullTime.new).to be true
      end
    end

    context 'when the authorship does not have a value for updated_by_owner_at' do
      let(:timestamp) { nil }

      it 'returns a null time' do
        expect(a.updated_by_owner).to be_a NullTime
      end
    end
  end
end
