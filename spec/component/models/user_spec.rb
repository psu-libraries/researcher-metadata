require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the users table', type: :model do
  subject(:user) { User.new }
  it { is_expected.to have_db_column(:activity_insight_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:first_name).of_type(:string) }
  it { is_expected.to have_db_column(:middle_name).of_type(:string) }
  it { is_expected.to have_db_column(:last_name).of_type(:string) }
  it { is_expected.to have_db_column(:webaccess_id).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:penn_state_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:is_admin).of_type(:boolean).with_options(default: false) }
  it { is_expected.to have_db_column(:pure_uuid).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_by_user_at).of_type(:datetime) }

  it { is_expected.to have_db_index(:activity_insight_identifier).unique(true) }
  it { is_expected.to have_db_index(:pure_uuid).unique(true) }
  it { is_expected.to have_db_index(:webaccess_id).unique(true) }
  it { is_expected.to have_db_index(:penn_state_identifier).unique(true) }
end

describe User, type: :model do
  subject(:user) { User.new }

  it_behaves_like "an application record"

  describe 'associations' do
    it { is_expected.to have_many(:authorships) }
    it { is_expected.to have_many(:publications).through(:authorships) }
    it { is_expected.to have_many(:user_contracts) }
    it { is_expected.to have_many(:contracts).through(:user_contracts) }
    it { is_expected.to have_many(:committee_memberships).inverse_of(:user) }
    it { is_expected.to have_many(:etds).through(:committee_memberships) }
    it { is_expected.to have_many(:news_feed_items) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:webaccess_id) }

    context "given an otherwise valid record" do
      subject { User.new(webaccess_id: 'abc123') }
      it { is_expected.to validate_uniqueness_of(:webaccess_id).case_insensitive }
      it { is_expected.to validate_uniqueness_of(:activity_insight_identifier).allow_nil }
      it { is_expected.to validate_uniqueness_of(:pure_uuid).allow_nil }
      it { is_expected.to validate_uniqueness_of(:penn_state_identifier).allow_nil }
    end
  end

  describe "saving a value for webaccess_id" do
    let(:u) { create :user, webaccess_id: wa_id }
    context "when the value contains uppercase letters" do
      let(:wa_id) { 'ABC123' }
      it "converts letters to lowercase before saving" do
        expect(u.webaccess_id).to eq 'abc123'
      end
    end
    context "when the value does not contain uppercase letters" do
      let(:wa_id) { 'xyz789' }
      it "saves the string without modifying it" do
        expect(u.webaccess_id).to eq 'xyz789'
      end
    end
  end

  describe "saving a value for penn_state_identifier" do
    let(:u) { create :user, penn_state_identifier: psu_id }
    context "when given nil" do
      let(:psu_id) { nil }
      it "saves the value as nil" do
        expect(u.penn_state_identifier).to eq nil
      end
    end
    context "when given an empty string" do
      let(:psu_id) { '' }
      it "saves the value as nil" do
        expect(u.penn_state_identifier).to eq nil
      end
    end
    context "when given a blank string" do
      let(:psu_id) { ' ' }
      it "saves the value as nil" do
        expect(u.penn_state_identifier).to eq nil
      end
    end
    context "when given a non-blank string" do
      let(:psu_id) { 'a' }
      it "saves the value of the string" do
        expect(u.penn_state_identifier).to eq 'a'
      end
    end
  end

  describe "saving a value for pure_uuid" do
    let(:u) { create :user, pure_uuid: pure_id }
    context "when given nil" do
      let(:pure_id) { nil }
      it "saves the value as nil" do
        expect(u.pure_uuid).to eq nil
      end
    end
    context "when given an empty string" do
      let(:pure_id) { '' }
      it "saves the value as nil" do
        expect(u.pure_uuid).to eq nil
      end
    end
    context "when given a blank string" do
      let(:pure_id) { ' ' }
      it "saves the value as nil" do
        expect(u.pure_uuid).to eq nil
      end
    end
    context "when given a non-blank string" do
      let(:pure_id) { 'a' }
      it "saves the value of the string" do
        expect(u.pure_uuid).to eq 'a'
      end
    end
  end

  describe "saving a value for activity_insight_identifier" do
    let(:u) { create :user, activity_insight_identifier: ai_id }
    context "when given nil" do
      let(:ai_id) { nil }
      it "saves the value as nil" do
        expect(u.activity_insight_identifier).to eq nil
      end
    end
    context "when given an empty string" do
      let(:ai_id) { '' }
      it "saves the value as nil" do
        expect(u.activity_insight_identifier).to eq nil
      end
    end
    context "when given a blank string" do
      let(:ai_id) { ' ' }
      it "saves the value as nil" do
        expect(u.activity_insight_identifier).to eq nil
      end
    end
    context "when given a non-blank string" do
      let(:ai_id) { 'a' }
      it "saves the value of the string" do
        expect(u.activity_insight_identifier).to eq 'a'
      end
    end
  end

  describe "deleting a user with authorships" do
    let(:u) { create :user }
    let!(:a) { create :authorship, user: u}
    it "also deletes the user's authorships" do
      u.destroy
      expect { a.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "deleting a user with user_contracts" do
    let(:u) { create :user }
    let!(:uc) { create :user_contract, user: u}
    it "also deletes the user's user_contracts" do
      u.destroy
      expect { uc.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '#admin?' do
    context "when the user's is_admin value is true" do
      before { user.is_admin = true }
      it "returns true" do
        expect(user.admin?).to eq true
      end
    end

    context "when the user's is_admin value is false" do
      before { user.is_admin = false }
      it "returns false" do
        expect(user.admin?).to eq false
      end
    end
  end

  describe '#name' do
    context "when the first, middle, and last names of the user are nil" do
      it "returns an empty string" do
        expect(user.name).to eq ''
      end
    end
    context "when the user has a first name" do
      before { user.first_name = 'first' }
      context "when the user has a middle name" do
        before { user.middle_name = 'middle' }
        context "when the user has a last name" do
          before { user.last_name = 'last' }
          it "returns the full name of the user" do
            expect(user.name).to eq 'first middle last'
          end
        end
        context "when the user has no last name" do
          before { user.last_name = '' }
          it "returns the full name of the user" do
            expect(user.name).to eq 'first middle'
          end
        end
      end
      context "when the user has no middle name" do
        before { user.middle_name = '' }
        context "when the user has a last name" do
          before { user.last_name = 'last' }
          it "returns the full name of the user" do
            expect(user.name).to eq 'first last'
          end
        end
        context "when the user has no last name" do
          before { user.last_name = '' }
          it "returns the full name of the user" do
            expect(user.name).to eq 'first'
          end
        end
      end
    end
    context "when the user has no first name" do
      before { user.first_name = '' }
      context "when the user has a middle name" do
        before { user.middle_name = 'middle' }
        context "when the user has a last name" do
          before { user.last_name = 'last' }
          it "returns the full name of the user" do
            expect(user.name).to eq 'middle last'
          end
        end
        context "when the user has no last name" do
          before { user.last_name = '' }
          it "returns the full name of the user" do
            expect(user.name).to eq 'middle'
          end
        end
      end
      context "when the user has no middle name" do
        before { user.middle_name = '' }
        context "when the user has a last name" do
          before { user.last_name = 'last' }
          it "returns the full name of the user" do
            expect(user.name).to eq 'last'
          end
        end
        context "when the user has no last name" do
          before { user.last_name = '' }
          it "returns an empty string" do
            expect(user.name).to eq ''
          end
        end
      end
    end
  end

  describe '#mark_as_updated_by_user' do
    let(:user) { User.new }
    before { allow(Time).to receive(:current).and_return Time.new(2018, 8, 23, 10, 7, 0) }

    it "sets the user's updated_by_user_at field to the current time" do
      user.mark_as_updated_by_user
      expect(user.updated_by_user_at).to eq Time.new(2018, 8, 23, 10, 7, 0)
    end
  end
end
