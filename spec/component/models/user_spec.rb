require 'component/component_spec_helper'

RSpec.describe User, type: :model do
  describe 'the users table' do
    subject(:user) { User.new }
    it { is_expected.to have_db_column(:activity_insight_identifier).of_type(:string) }
    it { is_expected.to have_db_column(:first_name).of_type(:string) }
    it { is_expected.to have_db_column(:middle_name).of_type(:string) }
    it { is_expected.to have_db_column(:last_name).of_type(:string) }
    it { is_expected.to have_db_column(:institution).of_type(:string) }
    it { is_expected.to have_db_column(:title).of_type(:string) }
    it { is_expected.to have_db_column(:webaccess_id).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:is_admin).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

    it { is_expected.to have_db_index :activity_insight_identifier }
    it { is_expected.to have_db_index(:webaccess_id).unique(true) }
  end

  describe User, type: :model do
    subject(:user) { User.new }

    describe 'associations' do
      it { is_expected.to have_many(:authorships) }
      it { is_expected.to have_many(:publications).through(:authorships) }
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of(:first_name) }
      it { is_expected.to validate_presence_of(:last_name) }
      it { is_expected.to validate_presence_of(:webaccess_id) }

      context "given an otherwise valid record" do
        subject { User.new(webaccess_id: 'abc123') }
        it { is_expected.to validate_uniqueness_of(:webaccess_id) }
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
  end
end
