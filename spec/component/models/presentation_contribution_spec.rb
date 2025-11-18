# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the presentation_contributions table', type: :model do
  subject { PresentationContribution.new }

  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:presentation_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:position).of_type(:integer) }
  it { is_expected.to have_db_column(:activity_insight_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:role).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:visible_in_profile).of_type(:boolean).with_options(default: false) }
  it { is_expected.to have_db_column(:position_in_profile).of_type(:integer) }

  it { is_expected.to have_db_index :user_id }
  it { is_expected.to have_db_index :presentation_id }
  it { is_expected.to have_db_index :activity_insight_identifier }

  it { is_expected.to have_db_foreign_key(:user_id) }
  it { is_expected.to have_db_foreign_key(:presentation_id) }
end

describe PresentationContribution, type: :model do
  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:presentation_contributions) }
    it { is_expected.to belong_to(:presentation).inverse_of(:presentation_contributions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:presentation_id) }
  end

  it { is_expected.to delegate_method(:presentation_label).to(:presentation).as(:label) }
  it { is_expected.to delegate_method(:presentation_organization).to(:presentation).as(:organization) }
  it { is_expected.to delegate_method(:presentation_location).to(:presentation).as(:location) }
  it { is_expected.to delegate_method(:user_webaccess_id).to(:user).as(:webaccess_id) }

  describe '.select_all_style' do
    let(:user) { create(:user) }
    let!(:pc1) { create(:presentation_contribution,
                        user: user,
                        visible_in_profile: true) }
    let!(:pc2) { create(:presentation_contribution,
                        user: user,
                        visible_in_profile: false) }

    context 'when at least one presentation is visible' do
      it 'returns display none' do
        expect(described_class.select_all_style(user.presentation_contributions)).to eq('display: none;')
      end
    end

    context 'when no presentations are visible' do
      it 'returns display inline-block' do
        pc1.update(visible_in_profile: false)
        expect(described_class.select_all_style(user.presentation_contributions)).to eq('display: inline-block;')
      end
    end
  end

  describe '.deselect_all_style' do
    let(:user) { create(:user) }
    let!(:pc1) { create(:presentation_contribution,
                        user: user,
                        visible_in_profile: true) }
    let!(:pc2) { create(:presentation_contribution,
                        user: user,
                        visible_in_profile: false) }

    let(:user2) { create(:user) }

    context 'when at least one presentation is visible' do
      it 'returns display inline-block' do
        expect(described_class.deselect_all_style(user.presentation_contributions)).to eq('display: inline-block;')
        expect(described_class.select_all_style(user.presentation_contributions)).to eq('display: none;')
      end
    end

    context 'when no presentations are visible' do
      it 'returns display none' do
        pc1.update(visible_in_profile: false)
        expect(described_class.deselect_all_style(user.presentation_contributions)).to eq('display: none;')
        expect(described_class.select_all_style(user.presentation_contributions)).to eq('display: inline-block;')
      end
    end

    context 'when user has no presentations' do
      it 'returns display none' do
        expect(described_class.deselect_all_style(user2.presentation_contributions)).to eq('display: none;')
        expect(described_class.select_all_style(user2.presentation_contributions)).to eq('display: none;')
      end
    end
  end
end
