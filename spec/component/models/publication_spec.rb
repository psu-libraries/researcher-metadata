require 'component/component_spec_helper'

RSpec.describe Publication, type: :model do
  describe 'the publications table' do
    subject { Publication.new }
    it { is_expected.to have_db_column(:title).of_type(:string) }
    it { is_expected.to have_db_column(:activity_insight_identifier).of_type(:string) }
    it { is_expected.to have_db_column(:activity_insight_updated_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:characteristic).of_type(:string) }
    it { is_expected.to have_db_column(:secondary_title).of_type(:text) }
    it { is_expected.to have_db_column(:source).of_type(:string) }
    it { is_expected.to have_db_column(:status).of_type(:string) }
    it { is_expected.to have_db_column(:volume).of_type(:string) }
    it { is_expected.to have_db_column(:issue).of_type(:string) }
    it { is_expected.to have_db_column(:edition).of_type(:string) }
    it { is_expected.to have_db_column(:page_range).of_type(:string) }
    it { is_expected.to have_db_column(:url).of_type(:text) }
    it { is_expected.to have_db_column(:isbn_issn).of_type(:string) }
    it { is_expected.to have_db_column(:abstract).of_type(:text) }
    it { is_expected.to have_db_column(:published_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:authorships) }
    it { is_expected.to have_many(:people).through(:authorships) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end
end
