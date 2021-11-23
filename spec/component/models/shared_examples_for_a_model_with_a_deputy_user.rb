# frozen_string_literal: true

shared_examples_for 'a model with a deputy user' do
  subject(:example) { described_class.new }

  context 'when setting the deputy with a valid user' do
    let(:user) { create(:user, primaries: [primary_user]) }
    let(:primary_user) { create(:user) }

    it { is_expected.to allow_value(user).for(:deputy) }
  end

  context 'when setting the deputy with an invalid user' do
    let(:user) { create(:user) }
    let(:primary_user) { create(:user) }

    it { is_expected.not_to allow_value(user).for(:deputy) }

    describe 'the error message' do
      subject { example.errors[:deputy] }

      before do
        example.deputy = user
        example.validate
      end

      let(:message) do
        I18n.t!("activerecord.errors.models.#{example.model_name.i18n_key}.attributes.deputy.not_assigned")
      end

      it { is_expected.to include(message) }
    end
  end
end
