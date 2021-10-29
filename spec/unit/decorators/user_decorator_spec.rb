# frozen_string_literal: true

require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/decorators/base_decorator'
require_relative '../../../app/decorators/user_decorator'

describe UserDecorator do
  describe 'masquerading?' do
    let(:mock_user) { instance_double('User') }
    let(:mock_impersonator) { instance_double('User') }

    context 'when an impersonator is present' do
      subject { described_class.new(user: mock_user, impersonator: mock_impersonator) }

      it { is_expected.to be_masquerading }
    end

    context 'when an impersonator is NOT present' do
      subject { described_class.new(user: mock_user) }

      it { is_expected.not_to be_masquerading }
    end
  end
end
