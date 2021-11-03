# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the deputy assignments table', type: :model do
  subject(:user) { DeputyAssignment.new }

  it { is_expected.to have_db_column(:primary_user_id).of_type(:integer) }
  it { is_expected.to have_db_column(:deputy_user_id).of_type(:integer) }
  it { is_expected.to have_db_column(:deactivated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:confirmed_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:is_active).of_type(:boolean) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:deputy_user_id) }
  it { is_expected.to have_db_index(:primary_user_id) }
  it { is_expected.to have_db_index([:primary_user_id, :deputy_user_id]).unique(true) }
end

describe DeputyAssignment, type: :model do
  subject(:user) { described_class.new }

  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:primary).class_name('User') }
    it { is_expected.to belong_to(:deputy).class_name('User') }
  end

  describe 'validations' do
    let(:primary_user) { create(:user) }
    let(:deputy_user) { create(:user) }
    let(:admin_user) { create(:user, is_admin: true) }

    it 'validates that primary and deputy are different' do
      assignment = described_class.create(primary: primary_user)
      expect(assignment).to allow_value(deputy_user).for(:deputy)
      expect(assignment).not_to allow_value(primary_user).for(:deputy)
      message = I18n.t!('activerecord.errors.models.deputy_assignment.attributes.deputy.same_as_primary')
      expect(assignment.errors[:deputy]).to include(message)
    end

    it 'validates that a primary cannot have the same deputy twice' do
      described_class.create!(primary: primary_user, deputy: deputy_user)
      assignment = described_class.new(primary: primary_user, deputy: deputy_user)
      expect(assignment).not_to be_valid
      message = I18n.t!('activerecord.errors.models.deputy_assignment.attributes.deputy.taken')
      expect(assignment.errors[:deputy]).to include(message)
    end

    it 'validates admins cannot be deputies' do
      assignment = described_class.new
      expect(assignment).not_to allow_value(admin_user).for(:deputy)
      message = I18n.t!('activerecord.errors.models.deputy_assignment.attributes.deputy.is_admin')
      expect(assignment.errors[:deputy]).to include(message)
    end

    it 'validates admins cannot be primaries' do
      assignment = described_class.new
      expect(assignment).not_to allow_value(admin_user).for(:primary)
      message = I18n.t!('activerecord.errors.models.deputy_assignment.attributes.primary.is_admin')
      expect(assignment.errors[:primary]).to include(message)
    end
  end

  context 'when a primary user has a deputy' do
    let(:primary_user) { create(:user) }
    let(:deputy_user) { create(:user) }
    let(:assignment) { described_class.create(primary: primary_user, deputy: deputy_user) }

    specify do
      expect(assignment.primary).to eq(primary_user)
      expect(assignment.deputy).to eq(deputy_user)
    end
  end
end
