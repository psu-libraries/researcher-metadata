# frozen_string_literal: true

require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/decorators/base_decorator'

describe BaseDecorator do
  let(:decorator) { described_class.new(mock) }
  let(:mock) { instance_spy('MockObject') }

  describe '#class' do
    subject { decorator.class }

    it { is_expected.to eq(RSpec::Mocks::InstanceVerifyingDouble) }
  end

  describe '#to_model' do
    subject { decorator.to_model }

    it { is_expected.to be_a(RSpec::Mocks::InstanceVerifyingDouble) }
  end

  # rubocop:disable RSpec/PredicateMatcher
  describe '#is_a?' do
    specify { expect(decorator.is_a?(RSpec::Mocks::InstanceVerifyingDouble)).to be_truthy }
    specify { expect(decorator.is_a?(Object)).to be_truthy }
    specify { expect(decorator).not_to be_a(String) }
  end
  # rubocop:enable RSpec/PredicateMatcher

  describe '#instance_of?' do
    specify { expect(decorator.instance_of?(mock.class)).to eq true }
  end
end
