require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the journals table', type: :model do
  subject { Journal.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:pure_uuid).of_type(:string) }
  it { is_expected.to have_db_column(:title).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:publisher_id).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :publisher_id }

  it { is_expected.to have_db_foreign_key(:publisher_id) }
end

describe Journal, type: :model do
  it_behaves_like "an application record"

  describe 'associations' do
    it { is_expected.to belong_to(:publisher).inverse_of(:journals).optional }
    it { is_expected.to have_many(:publications).inverse_of(:journal) }
  end

  describe '.ordered_by_publication_count' do
    let!(:j1) { create :journal, title: 'a' }
    let!(:j2) { create :journal, title: 'b' }
    let!(:j3) { create :journal, title: 'c' }

    before do
      2.times { create :publication, journal: j2 }
      create :publication, journal: j3
    end

    it "returns all journal records in order by the number of publications with which they're associated" do
      expect(Journal.order(:title).ordered_by_publication_count).to eq [j2, j3, j1]
    end
  end

  describe '.ordered_by_psu_publication_count' do
    xit "returns all journal records in order by the number of their publications that were authored by PSU faculty at the University" do
      
    end
  end

    describe '#psu_publication_count' do
    let!(:journal) { create :journal }
    let!(:pub1) { create :publication, journal: journal, published_on: Date.new(2001, 1, 1) }
    let!(:pub2) { create :publication, journal: journal }
    let!(:pub3) { create :publication, journal: journal, published_on: Date.new(1999, 1, 1) }
    let!(:pub4) { create :publication, journal: journal, published_on: Date.new(2001, 1, 2) }
    let!(:pub5) { create :publication, journal: journal, published_on: Date.new(2003, 1, 1) }
    let!(:user) { create :user }
    let!(:org) { create :organization }

    before do
      create :authorship, user: user, publication: pub1
      create :authorship, user: user, publication: pub2
      create :authorship, user: user, publication: pub3
      create :authorship, user: user, publication: pub4
      create :authorship, user: user, publication: pub5

      create :user_organization_membership,
             user: user,
             organization: org,
             started_on: Date.new(2000, 1, 1),
             ended_on: Date.new(2002, 1, 1)
    end
    it "returns the number of publications associated with the publisher that were published by PSU faculty while they were PSU faculty" do
      expect(journal.psu_publication_count).to eq 2
    end
  end

  describe '.ordered_by_title' do
    let!(:j1) { create :journal, title: 'c' }
    let!(:j2) { create :journal, title: 'a' }
    let!(:j3) { create :journal, title: 'b' }

    it "returns all journal records in alphabetical order by name" do
      expect(Journal.ordered_by_title).to eq [j2, j3, j1]
    end
  end

  describe '#publication_count' do
    let!(:journal) { create :journal }
    before do
      2.times { create :publication, journal: journal }
    end
    it "returns the number of publications that are associated with the journal" do
      expect(journal.publication_count).to eq 2
    end
  end
end
