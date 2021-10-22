# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the open_access_locations table', type: :model do
  subject { OpenAccessLocation.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_id).of_type(:integer) }
  it { is_expected.to have_db_column(:host_type).of_type(:string) }
  it { is_expected.to have_db_column(:is_best).of_type(:boolean) }
  it { is_expected.to have_db_column(:license).of_type(:string) }
  it { is_expected.to have_db_column(:oa_date).of_type(:date) }
  it { is_expected.to have_db_column(:source).of_type(:string) }
  it { is_expected.to have_db_column(:source_updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:url).of_type(:string) }
  it { is_expected.to have_db_column(:landing_page_url).of_type(:string) }
  it { is_expected.to have_db_column(:pdf_url).of_type(:string) }
  it { is_expected.to have_db_column(:version).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :publication_id }

  it { is_expected.to have_db_foreign_key(:publication_id) }
end

describe OpenAccessLocation, type: :model do
  subject(:oal) { described_class.new }

  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:publication).inverse_of(:open_access_locations) }
  end

  specify do
    expect(oal).to define_enum_for(:source)
      .backed_by_column_of_type(:string)
      .with_values(
        user: 'user',
        scholarsphere: 'scholarsphere',
        open_access_button: 'open_access_button',
        unpaywall: 'unpaywall',
        dickinson_ideas: 'dickinson_ideas',
        psu_law_elibrary: 'psu_law_elibrary'
      )
      .with_prefix(:source)
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:publication) }
    it { is_expected.not_to allow_value(nil).for(:source) }
    it { is_expected.to validate_presence_of(:url) }
  end

  describe '#source' do
    it 'is a Source value object' do
      oal = described_class.new(source: Source::USER)
      expect(oal.source).to be_a(Source)
      expect(oal.source.to_s).to eq Source::USER
    end
  end

  describe '#name' do
    let(:oal) { described_class.new(url: 'https://example.com/article', source: Source::USER) }

    it "returns a string that includes the location's URL and source" do
      expect(oal.name).to eq 'https://example.com/article (User)'
    end
  end
end
