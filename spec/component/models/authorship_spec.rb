require 'component/component_spec_helper'

describe 'the authorships table', type: :model do
  subject { Authorship.new }

  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:author_number).of_type(:integer) }
  it { is_expected.to have_db_column(:activity_insight_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:pure_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :user_id }
  it { is_expected.to have_db_index :publication_id }
  it { is_expected.to have_db_index(:activity_insight_identifier).unique }
  it { is_expected.to have_db_index(:pure_identifier).unique }

  it { is_expected.to have_db_foreign_key(:user_id) }
  it { is_expected.to have_db_foreign_key(:publication_id) }
end

describe Authorship, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:publication) }
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
end
