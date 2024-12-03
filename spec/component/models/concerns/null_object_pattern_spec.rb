# frozen_string_literal: true

require 'component/component_spec_helper'

RSpec.describe NullObjectPattern do
  subject do
    Class.new do
      include NullObjectPattern
    end.new
  end

  it { is_expected.to be_nil }
  it { is_expected.to be_empty }
  it { is_expected.to be_blank }
  it { is_expected.not_to be_present }

  its(:anything) { is_expected.to be_nil }
end
