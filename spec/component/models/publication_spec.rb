require 'component/component_spec_helper'

RSpec.describe Publication, type: :model do
  describe 'the publications table' do
    subject { Publication.new }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:authorships) }
    it { is_expected.to have_many(:imports).class_name(:PublicationImport) }
    it { is_expected.to have_many(:people).through(:authorships) }
  end
end
