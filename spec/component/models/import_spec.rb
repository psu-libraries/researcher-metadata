# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the imports table', type: :model do
  subject { Import.new }

  it { is_expected.to have_db_column(:source).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:started_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:completed_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
end

describe Import, type: :model do
  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to have_many(:source_publications) }
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:source).in_array(['Pure', 'Activity Insight']) }
  end

  describe '.latest_completed_from_pure' do
    context 'when there are no import records' do
      it 'returns nil' do
        expect(described_class.latest_completed_from_pure).to be_nil
      end
    end

    context 'when there is only an incomplete import from Pure' do
      before { create(:import, source: 'Pure', completed_at: nil) }

      it 'returns nil' do
        expect(described_class.latest_completed_from_pure).to be_nil
      end
    end

    context 'when there is only a completed import from Activity Insight' do
      before { create(:import, source: 'Activity Insight', completed_at: Time.current) }

      it 'returns nil' do
        expect(described_class.latest_completed_from_pure).to be_nil
      end
    end

    context 'when there are multiple import records' do
      let!(:import) { create(:import, source: 'Pure', completed_at: 1.week.ago) }

      before do
        create(:import, source: 'Activity Insight', completed_at: 1.day.ago)
        create(:import, source: 'Pure', completed_at: nil)
        create(:import, source: 'Pure', completed_at: 1.year.ago)
        create(:import, source: 'Pure', completed_at: 1.month.ago)
      end

      it 'returns the most recently completed import from Pure' do
        expect(described_class.latest_completed_from_pure).to eq import
      end
    end
  end
end
