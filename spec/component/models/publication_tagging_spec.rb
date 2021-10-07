require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the publication_taggings table', type: :model do
  subject { PublicationTagging.new }

  it { is_expected.to have_db_column(:tag_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:rank).of_type(:float) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :tag_id }
  it { is_expected.to have_db_index :publication_id }

  it { is_expected.to have_db_foreign_key(:tag_id) }
  it { is_expected.to have_db_foreign_key(:publication_id) }
end

describe PublicationTagging, type: :model do
  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:tag).inverse_of(:publication_taggings) }
    it { is_expected.to belong_to(:publication).inverse_of(:taggings) }

    it { is_expected.to delegate_method(:name).to(:tag) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:tag_id) }
    it { is_expected.to validate_presence_of(:publication_id) }

    context 'given otherwise valid data' do
      subject { PublicationTagging.new(tag: create(:tag), publication: create(:publication)) }

      it { is_expected.to validate_uniqueness_of(:publication_id).scoped_to(:tag_id) }
    end
  end
end
