# frozen_string_literal: true

require 'component/component_spec_helper'

describe CurrentUserBuilder do
  subject { described_class.call(current_user: user, current_session: session) }

  let(:session) { Hash.new }

  context 'when the current user is nil' do
    let(:user) { nil }

    it { is_expected.to be_a(NullUser) }
    its(:impersonator) { is_expected.to be_nil }
  end

  context 'when the current user is not an admin or a deputy' do
    let(:user) { build(:user, is_admin: false) }

    it { is_expected.to be_a(UserDecorator) }
    it { is_expected.not_to be_masquerading }
    it { is_expected.to eq(user) }
    its(:impersonator) { is_expected.to be_nil }
  end

  context 'when the current user is an admin NOT posing as another user' do
    let(:user) { build(:user, is_admin: true) }

    it { is_expected.to be_a(UserDecorator) }
    it { is_expected.not_to be_masquerading }
    it { is_expected.to eq(user) }
    its(:impersonator) { is_expected.to be_nil }
  end

  context 'when the current user is an admin that is posing as another user' do
    let(:user) { build(:user, is_admin: true) }
    let(:primary_user) { build(:user) }
    let(:session) { { MasqueradingBehaviors::SESSION_ID => 'primary-user-id' } }

    before do
      allow(User).to receive(:find).with('primary-user-id').and_return(primary_user)
    end

    it { is_expected.to be_a(UserDecorator) }
    it { is_expected.to be_masquerading }
    it { is_expected.to eq(primary_user) }
    its(:impersonator) { is_expected.to eq(user) }
  end

  context 'when the current user is a deputy posing as their primary' do
    let(:user) { build(:user) }
    let(:primary_user) { build(:user, deputies: [user]) }
    let(:session) { { MasqueradingBehaviors::SESSION_ID => 'primary-user-id' } }

    before do
      allow(User).to receive(:find).with('primary-user-id').and_return(primary_user)
      allow(primary_user).to receive(:available_deputies).and_return([user])
    end

    it { is_expected.to be_a(UserDecorator) }
    it { is_expected.to be_masquerading }
    it { is_expected.to eq(primary_user) }
    its(:impersonator) { is_expected.to eq(user) }
  end

  context 'when the current user is no longer the deputy, but still has an active session id for the primary' do
    let(:user) { build(:user) }
    let(:primary_user) { build(:user) }
    let(:session) { { MasqueradingBehaviors::SESSION_ID => 'primary-user-id' } }

    before do
      allow(User).to receive(:find).with('primary-user-id').and_return(primary_user)
      allow(primary_user).to receive(:available_deputies).and_return([])
    end

    it { is_expected.to be_a(UserDecorator) }
    it { is_expected.not_to be_masquerading }
    it { is_expected.to eq(user) }
    its(:impersonator) { is_expected.to be_nil }
  end

  context 'when the primary user no longer exists, but the current user still has an active session id for them' do
    let(:user) { build(:user) }
    let(:session) { { MasqueradingBehaviors::SESSION_ID => 'primary-user-id' } }

    before do
      allow(User).to receive(:find).with('primary-user-id').and_return(nil)
    end

    it { is_expected.to be_a(UserDecorator) }
    it { is_expected.not_to be_masquerading }
    it { is_expected.to eq(user) }
    its(:impersonator) { is_expected.to be_nil }
  end
end
