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
  subject(:waiver) { InternalPublicationWaiver.new }

  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:authorship).inverse_of(:waiver) }
    it { is_expected.to have_one(:user).through(:authorship) }
    it { is_expected.to have_one(:publication).through(:authorship) }
    it { is_expected.to have_one(:external_publication_waiver) }
  end

  it { is_expected.to delegate_method(:title).to(:authorship).allow_nil }
  it { is_expected.to delegate_method(:abstract).to(:authorship) }
  it { is_expected.to delegate_method(:doi).to(:authorship) }
  it { is_expected.to delegate_method(:published_by).to(:authorship) }

  describe '#publisher' do
    it 'returns nil' do
      expect(waiver.publisher).to be_nil
    end
  end

  describe '#publication_title' do
    before { waiver.authorship = Authorship.new(publication: Publication.new(title: 'The Title')) }

    it "returns the authorship's publication's title" do
      expect(waiver.publication_title).to eq 'The Title'
    end
  end

  describe '#journal_title' do
    before { waiver.authorship = Authorship.new(publication: Publication.new(journal_title: 'The Title')) }

    it "returns the authorship's publication's journal title" do
      expect(waiver.journal_title).to eq 'The Title'
    end
  end
end
