# frozen_string_literal: true

require 'component/component_spec_helper'

describe CurrentUserBuilder do
  subject { described_class.call(current_user: user, current_session: session) }

  let(:session) { Hash.new }

  context 'when the current user is nil' do
    let(:user) { nil }

    it { is_expected.to be_a(NullUser) }
  end

  context 'when the current user is not an admin' do
    let(:user) { build(:user, is_admin: false) }

    it { is_expected.to be_a(UserDecorator) }
    it { is_expected.not_to be_masquerading }
  end

  context 'when the current user is an admin' do
    let(:user) { build(:user, is_admin: true) }

    it { is_expected.to be_a(UserDecorator) }
    it { is_expected.not_to be_masquerading }
  end

  context 'when the current is an admin that is posing as another user' do
    let(:user) { build(:user, is_admin: true) }
    let(:session) { { pretend_user_id: 'user-to-pretend' } }

    before do
      allow(User).to receive(:find).with('user-to-pretend').and_return('mock user')
    end

    it { is_expected.to be_a(UserDecorator) }
    it { is_expected.to be_masquerading }
  end
end
