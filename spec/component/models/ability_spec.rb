# frozen_string_literal: true

require 'component/component_spec_helper'
require 'cancan/matchers'

describe Ability do
  subject { described_class.new(user) }

  context 'when given an admin user' do
    let(:user) { create :user, is_admin: true }

    it { is_expected.to be_able_to(:manage, :all) }
  end

  context 'when given a non-admin user that own an organization' do
    let(:user) { create :user, is_admin: false }
    let(:org) { create :organization, owner: user }
    let(:managed_user) { create :user }
    let!(:other_user) { create :user }

    before { create :user_organization_membership, user: managed_user, organization: org }

    it { is_expected.not_to be_able_to(:manage, :all) }
    it { is_expected.to be_able_to(:access, :rails_admin) }
    it { is_expected.to be_able_to(:dashboard, :all) }
    it { is_expected.to be_able_to(:index, User) }
    it { is_expected.to be_able_to(:edit, managed_user) }
    it { is_expected.to be_able_to(:toggle, managed_user) }
    it { is_expected.not_to be_able_to(:edit, other_user) }
    it { is_expected.not_to be_able_to(:toggle, other_user) }
  end

  context 'when given a non-admin user that does not own any organizations' do
    let(:user) { create :user, is_admin: false }

    it { is_expected.not_to be_able_to(:manage, :all) }
    it { is_expected.not_to be_able_to(:access, :rails_admin) }
  end

  context 'when not given a user' do
    let(:user) { nil }

    it { is_expected.not_to be_able_to(:manage, :all) }
    it { is_expected.not_to be_able_to(:access, :rails_admin) }
  end
end
