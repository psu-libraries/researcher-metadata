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
  it { is_expected.to have_db_column(:active_uniqueness_key).of_type(:integer).with_options(default: 0) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:deputy_user_id) }
  it { is_expected.to have_db_index(:primary_user_id) }
  it { is_expected.to have_db_index([:primary_user_id, :deputy_user_id, :active_uniqueness_key]).unique(true) }
end

describe DeputyAssignment, type: :model do
  subject(:user) { described_class.new }

  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:primary).class_name('User') }
    it { is_expected.to belong_to(:deputy).class_name('User') }
  end

  describe 'scopes' do
    describe '.active' do
      let!(:active) { create :deputy_assignment, is_active: true }

      before { create :deputy_assignment, is_active: false }

      it 'returns active models' do
        expect(described_class.active).to contain_exactly(active)
      end
    end

    describe '.confirmed' do
      let!(:confirmed) { create :deputy_assignment, confirmed_at: Time.zone.now - 1.day }

      before { create :deputy_assignment, confirmed_at: nil }

      it 'returns confirmed models' do
        expect(described_class.confirmed).to contain_exactly(confirmed)
      end
    end
  end

  describe 'validations' do
    let(:primary_user) { create(:user) }
    let(:deputy_user) { create(:user) }
    let(:admin_user) { create(:user, is_admin: true) }

    it 'validates that primary and deputy are different' do
      assignment = described_class.create(primary: primary_user)
      expect(assignment).to allow_value(deputy_user).for(:deputy)
      expect(assignment).not_to allow_value(primary_user).for(:deputy)
        .with_message(I18n.t!('activerecord.errors.models.deputy_assignment.attributes.deputy.same_as_primary'))
    end

    it 'validates (primary, deputy) are unique among _active_ DeputyAssignments' do
      existing_assignment = described_class.create!(primary: primary_user, deputy: deputy_user)
      new_assignment = described_class.new(primary: primary_user)

      # When existing assignment is active, new assignment is active
      existing_assignment.update!(is_active: true)
      new_assignment.is_active = true
      expect(new_assignment).not_to allow_value(deputy_user).for(:deputy)
        .with_message(I18n.t!('activerecord.errors.models.deputy_assignment.attributes.deputy.taken'))

      # When existing assignment is active, but new assignment is inactive
      existing_assignment.update!(is_active: true)
      new_assignment.is_active = false
      expect(new_assignment).to allow_value(deputy_user).for(:deputy)

      # When existing assignment is inactive, but new assignment is active
      existing_assignment.deactivate!
      new_assignment.is_active = true
      expect(new_assignment).to allow_value(deputy_user).for(:deputy)

      # When existing assignment is inactive, and new assignment is inactive
      existing_assignment.deactivate!
      new_assignment.is_active = false
      expect(new_assignment).to allow_value(deputy_user).for(:deputy)
    end

    it 'validates admins cannot be deputies' do
      assignment = described_class.new
      expect(assignment).not_to allow_value(admin_user).for(:deputy)
        .with_message(I18n.t!('activerecord.errors.models.deputy_assignment.attributes.deputy.is_admin'))
    end

    it 'validates admins cannot be primaries' do
      assignment = described_class.new
      expect(assignment).not_to allow_value(admin_user).for(:primary)
        .with_message(I18n.t!('activerecord.errors.models.deputy_assignment.attributes.primary.is_admin'))
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

  describe 'default values' do
    it 'initializes is_active to true' do
      expect(described_class.new.is_active).to eq true
      expect(described_class.new(is_active: false).is_active).to eq false
    end

    describe 'initializing active_uniqueness_key' do
      context 'when `is_active` is true' do
        it 'is initialized to 0' do
          assignment = described_class.create(primary: create(:user), deputy: create(:user), is_active: true)

          assignment.reload
          expect(assignment.active_uniqueness_key).to eq 0
        end
      end

      context 'when `is_active` is false' do
        it "is initialized to the record's id" do
          assignment = described_class.create(primary: create(:user), deputy: create(:user), is_active: false)

          assignment.reload
          expect(assignment.active_uniqueness_key).to eq assignment.id
        end
      end
    end
  end

  describe '#confirmed? and #pending? (inverses)' do
    it 'returns true if confirmed_at is present' do
      da = described_class.new(confirmed_at: Time.zone.now)
      expect(da).to be_confirmed
      expect(da).not_to be_pending

      da.confirmed_at = nil
      expect(da).not_to be_confirmed
      expect(da).to be_pending
    end
  end

  describe '#confirm!' do
    let(:assignment) { create :deputy_assignment, :unconfirmed }

    it 'sets the appropriate flags to confirm an assignment' do
      expect {
        assignment.confirm!
      }.to change(assignment.tap(&:reload), :confirmed?)
        .from(false).to(true)
    end
  end

  describe '#deactivate!' do
    let(:assignment) { create :deputy_assignment, is_active: is_active }

    context 'when is_active: true' do
      let(:is_active) { true }

      it 'sets the appropriate flags to deactivate an assignment' do
        assignment.deactivate!
        assignment.reload
        expect(assignment.is_active).to eq false
        expect(assignment.deactivated_at).to be_within(2.seconds).of(Time.zone.now)
        expect(assignment.active_uniqueness_key).to eq assignment.id
      end
    end

    context 'when is_active: false' do
      let(:is_active) { false }

      it 'does nothing' do
        expect {
          assignment.deactivate!
        }.not_to change(assignment, :deactivated_at)
      end
    end
  end
end
