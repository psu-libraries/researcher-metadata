require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the internal_publication_waivers table', type: :model do
  subject { InternalPublicationWaiver.new }

  it { is_expected.to have_db_column(:authorship_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:reason_for_waiver).of_type(:text) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :authorship_id }

  it { is_expected.to have_db_foreign_key(:authorship_id) }
end

describe InternalPublicationWaiver, type: :model do
  it_behaves_like "an application record"

  describe 'associations' do
    it { is_expected.to belong_to(:authorship).inverse_of(:waiver) }
    it { is_expected.to have_one(:user).through(:authorship) }
    it { is_expected.to have_one(:publication).through(:authorship) }
  end

  it { is_expected.to delegate_method(:title).to(:authorship) }
  it { is_expected.to delegate_method(:abstract).to(:authorship) }
  it { is_expected.to delegate_method(:doi).to(:authorship) }
  it { is_expected.to delegate_method(:published_by).to(:authorship) }
end
