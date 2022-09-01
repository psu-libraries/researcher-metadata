# frozen_string_literal: true

require 'component/component_spec_helper'

RSpec.describe OaNotificationSetting, type: :model do
  it { is_expected.to have_db_column(:email_cap).of_type(:integer) }
  it { is_expected.to have_db_column(:is_active).of_type(:boolean) }

  before do
    described_class.destroy_all
  end

  describe '#instance' do
    context 'when a record already exists' do
      it 'returns the record' do
        setting = described_class.create(email_cap: 100, is_active: true, singleton_guard: 0)
        expect(described_class.instance).to eq setting
      end
    end

    context "when a record doesn't exist" do
      it 'creates new record with seed data record' do
        expect(described_class.instance.email_cap).to eq 300
      end
    end
  end

  describe '#email_cap' do
    it "returns the first record's email_cap" do
      setting = described_class.create(email_cap: 100, is_active: true, singleton_guard: 0)
      expect(described_class.email_cap).to eq setting.email_cap
    end
  end

  describe '#is_not_active' do
    context "when first record's is_active bool is true" do
      it "returns false" do
        expect(described_class.is_not_active).to eq false
      end
    end

    context "when first record's is_active bool is false" do
      it "returns true" do
        described_class.instance.is_active = false
        expect(described_class.is_not_active).to eq true
      end
    end
  end
end
