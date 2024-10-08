# frozen_string_literal: true

shared_examples_for 'a model with a deputy user' do
  subject(:example) { described_class.new }

  context 'when setting the deputy with user that is a deputy' do
    let(:user) { create(:user, primaries: [primary_user]) }
    let(:primary_user) { create(:user) }

    it { is_expected.to allow_value(user).for(:deputy) }
  end

  context 'when setting the deputy with user that is not a deputy' do
    let(:user) { create(:user) }

    it { is_expected.to allow_value(user).for(:deputy) }
  end
end
