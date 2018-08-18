require 'component/component_spec_helper'

describe 'the tags_table', type: :model do
  subject { Tag.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:source).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:name) }
end

describe Tag, type: :model do
  subject(:tag) { Tag.new }

  describe 'associations' do
    it { is_expected.to have_many(:publication_taggings) }
    it { is_expected.to have_many(:publications).through(:publication_taggings) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }

    context "given an otherwise valid record" do
      subject { Tag.new(name: 'abc') }
      it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    end
  end

  describe "saving a value for name" do
    let(:t) { create :tag, name: tag_name }
    context "when the value contains upper and lowercase letters" do
      let(:tag_name) { 'ABC DeF ghi' }
      it "titleizes before saving" do
        expect(t.name).to eq 'Abc Def Ghi'
      end
    end
  end
end
