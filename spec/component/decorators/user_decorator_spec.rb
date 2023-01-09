# frozen_string_literal: true

require 'component/component_spec_helper'

describe UserDecorator do
  describe 'masquerading?' do
    let(:mock_user) { instance_double(User) }
    let(:mock_impersonator) { instance_double(User) }

    context 'when an impersonator is present' do
      subject { described_class.new(user: mock_user, impersonator: mock_impersonator) }

      it { is_expected.to be_masquerading }
    end

    context 'when an impersonator is NOT present' do
      subject { described_class.new(user: mock_user) }

      it { is_expected.not_to be_masquerading }
    end
  end

  describe 'equality' do
    subject(:decorator) { described_class.new(user: user) }

    let(:user) { build_stubbed(:user) }

    it 'has symmetric ==' do
      expect(decorator == user).to be true
      expect(user == decorator).to be true
    end
  end
end
