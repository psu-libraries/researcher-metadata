# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the publishers table', type: :model do
  subject { Publisher.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:pure_uuid).of_type(:string) }
  it { is_expected.to have_db_column(:name).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
end

describe Publisher, type: :model do
  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to have_many(:journals).inverse_of(:publisher) }
    it { is_expected.to have_many(:publications).through(:journals) }
  end

  describe '.ordered_by_publication_count' do
    let!(:p1) { create :publisher, name: 'a' }
    let!(:p2) { create :publisher, name: 'b' }
    let!(:p3) { create :publisher, name: 'c' }

    let!(:j1) { create :journal, publisher: p2 }
    let!(:j2) { create :journal, publisher: p3 }

    before do
      create_list :publication, 2, journal: j1
      create :publication, journal: j2
    end

    it "returns all publisher records in order by the number of publications with which they're associated" do
      expect(described_class.order(:name).ordered_by_publication_count).to eq [p2, p3, p1]
    end
  end

  describe '.ordered_by_psu_publication_count' do
    xit 'returns all publisher records in order by the number of their publications that were authored by PSU faculty at the University' do
    end
  end

  describe '.ordered_by_name' do
    let!(:p1) { create :publisher, name: 'c' }
    let!(:p2) { create :publisher, name: 'a' }
    let!(:p3) { create :publisher, name: 'b' }

    it 'returns all publisher records in alphabetical order by name' do
      expect(described_class.ordered_by_name).to eq [p2, p3, p1]
    end
  end

  describe '#publication_count' do
    let!(:publisher) { create :publisher }
    let!(:journal1) { create :journal, publisher: publisher }
    let!(:journal2) { create :journal, publisher: publisher }

    before do
      create_list :publication, 2, journal: journal1
      create_list :publication, 2, journal: journal2
    end

    it 'returns the number of publications that are associated with the publisher' do
      expect(publisher.publication_count).to eq 4
    end
  end

  describe '#psu_publication_count' do
    let!(:publisher) { create :publisher }
    let!(:journal1) { create :journal, publisher: publisher }
    let!(:journal2) { create :journal, publisher: publisher }
    let!(:pub1) { create :publication, journal: journal1, published_on: Date.new(2001, 1, 1) }
    let!(:pub2) { create :publication, journal: journal2 }
    let!(:pub3) { create :publication, journal: journal2, published_on: Date.new(1999, 1, 1) }
    let!(:pub4) { create :publication, journal: journal2, published_on: Date.new(2001, 1, 2) }
    let!(:pub5) { create :publication, journal: journal2, published_on: Date.new(2003, 1, 1) }
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

    it 'returns the number of publications associated with the publisher that were published by PSU faculty while they were PSU faculty' do
      expect(publisher.psu_publication_count).to eq 2
    end
  end
end
