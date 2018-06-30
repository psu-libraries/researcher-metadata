require 'component/component_spec_helper'

RSpec.describe Publication, type: :model do
  describe 'the publications table' do
    subject { Publication.new }
    it { is_expected.to have_db_column(:title).of_type(:string) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:authorships) }
    it { is_expected.to have_many(:people).through(:authorships) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end
end
