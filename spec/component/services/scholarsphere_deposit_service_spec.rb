require 'component/component_spec_helper'

describe ScholarsphereDepositService do
  let(:service) { ScholarsphereDepositService.new(deposit, user) }
  let(:user) { double 'user' }
  let(:deposit) { double 'scholarsphere work deposit' }

  describe '#create' do
    xit
  end
end
