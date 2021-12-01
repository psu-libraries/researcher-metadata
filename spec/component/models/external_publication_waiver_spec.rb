# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the external_publication_waivers table', type: :model do
  subject { ExternalPublicationWaiver.new }

  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_title).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:reason_for_waiver).of_type(:text) }
  it { is_expected.to have_db_column(:abstract).of_type(:text) }
  it { is_expected.to have_db_column(:doi).of_type(:string) }
  it { is_expected.to have_db_column(:journal_title).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:publisher).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:internal_publication_waiver_id).of_type(:integer) }
  it { is_expected.to have_db_column(:deputy_user_id).of_type(:integer) }

  it { is_expected.to have_db_index :user_id }
  it { is_expected.to have_db_index :internal_publication_waiver_id }
  it { is_expected.to have_db_index :deputy_user_id }

  it { is_expected.to have_db_foreign_key(:user_id) }
  it { is_expected.to have_db_foreign_key(:internal_publication_waiver_id) }
  it { is_expected.to have_db_foreign_key(:deputy_user_id).to_table(:users).with_name(:external_publication_waivers_deputy_user_id_fk) }
end

describe ExternalPublicationWaiver, type: :model do
  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:external_publication_waivers) }
    it { is_expected.to belong_to(:internal_publication_waiver).inverse_of(:external_publication_waiver).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:publication_title) }
    it { is_expected.to validate_presence_of(:journal_title) }
  end

  describe '.not_linked' do
    let!(:w1) { create :external_publication_waiver }
    let!(:w2) { create :external_publication_waiver, internal_publication_waiver: int_waiver }
    let(:int_waiver) { create :internal_publication_waiver }

    it 'returns external publication waivers that are not associated with an internal publication waiver' do
      expect(described_class.not_linked).to eq [w1]
    end
  end

  describe '#title' do
    let(:waiver) { described_class.new(publication_title: 'The Title') }

    it 'returns the value for publication title' do
      expect(waiver.title).to eq 'The Title'
    end
  end

  describe '#matching_publications' do
    let(:waiver) { described_class.new(publication_title: 'A Publication with a Distinct Title of Some Sort') }
    let!(:pub1) { create :publication, title: 'A test publication with a long, distinct title of some sort' }
    let!(:pub2) { create :publication, title: 'Another publication', secondary_title: 'with a longer, distinct title of some sort' }
    let!(:pub3) { create :publication, title: 'Some Other Publication' }
    let!(:pub4) { create :publication, title: 'A publication with a long, but rather different title' }
    let!(:pub5) { create :publication, title: 'A Publication with a Distinct Title of Some Sort' }

    it 'returns all publications with a title that closely matches the title in the waiver' do
      expect(waiver.matching_publications).to match_array [pub1, pub2, pub5]
    end
  end

  describe '#has_matching_publications' do
    let(:waiver) { described_class.new(publication_title: 'A Publication with a Distinct Title of Some Sort') }

    context 'when there is a publication with a title that closely matches the title in the waiver' do
      let!(:pub) { create :publication, title: 'A test publication with a long, distinct title of some sort' }

      it 'returns true' do
        expect(waiver.has_matching_publications).to eq true
      end
    end

    context 'when there are no publications with a title that closely matches the title in the waiver' do
      let!(:pub) { create :publication, title: 'A publication with a long, but rather different title' }

      it 'returns false' do
        expect(waiver.has_matching_publications).to eq false
      end
    end
  end
end
