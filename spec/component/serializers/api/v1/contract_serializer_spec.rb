require 'component/component_spec_helper'

describe API::V1::ContractSerializer do
  let(:contract) { create :contract,
                             title: 'contract 1',
                             contract_type: 'Grant',
                             sponsor: 'a sponsor',
                             status: 'Awarded',
                             amount: 1000000,
                             ospkey: 12345,
                             award_start_on: Date.new(2017, 9, 1),
                             award_end_on: Date.new(2018, 8, 1) }

  describe "data attributes" do
    subject { serialized_data_attributes(contract) }
    it { is_expected.to include(:title => 'contract 1') }
    it { is_expected.to include(:contract_type => 'Grant') }
    it { is_expected.to include(:sponsor => 'a sponsor') }
    it { is_expected.to include(:status => 'Awarded') }
    it { is_expected.to include(:amount => 1000000) }
    it { is_expected.to include(:ospkey => 12345) }
    it { is_expected.to include(:award_start_on => '2017-09-01') }
    it { is_expected.to include(:award_end_on => '2018-08-01') }
  end
end
