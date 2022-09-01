# frozen_string_literal: true

require 'component/component_spec_helper'

RSpec.describe OaNotificationSetting, type: :model do
  before do
    described_class.destroy_all
  end

  it { is_expected.to have_db_column(:email_cap).of_type(:integer) }
  it { is_expected.to have_db_column(:is_active).of_type(:boolean) }

  describe '#instance' do
    context 'when a record already exists' do
      it 'returns the record' do
        setting = described_class.create(email_cap: 300, is_active: true, singleton_guard: 0)
        expect(described_class.instance).to eq setting
      end
    end

    context "when a record doesn't exist" do
      it 'creates new record with seed data record' do
        expect(described_class.instance.email_cap).to eq 100
      end
    end
  end

  describe '#email_cap' do
    it "returns the first record's email_cap" do
      setting = described_class.create(email_cap: 300, is_active: true, singleton_guard: 0)
      expect(described_class.email_cap).to eq setting.email_cap
    end
  end

  describe '#not_active?' do
    context "when first record's is_active bool is true" do
      it 'returns false' do
        expect(described_class.not_active?).to be false
      end
    end

    context "when first record's is_active bool is false" do
      it 'returns true' do
        described_class.create(email_cap: 300, is_active: false, singleton_guard: 0)
        expect(described_class.not_active?).to be true
      end
    end
  end

  describe 'validation' do
    context 'when creating a record when another already exists' do
      it 'raises a RecordNotUnique error' do
        described_class.instance
        expect { described_class.create email_cap: 100, is_active: true, singleton_guard: 0 }
          .to raise_error ActiveRecord::RecordNotUnique
      end
    end

    context 'when creating a record with a singleton_guard that is not 0' do
      it 'raises a RecordInvalid error' do
        expect(described_class.create(email_cap: 100, is_active: true, singleton_guard: 1).valid?).to be false
      end
    end
  end
end
