require 'component/component_spec_helper'

describe API::V1::OrganizationSerializer do
  let(:org) { create :organization, name: 'Test Org' }

  describe "data attributes" do
    subject { serialized_data_attributes(org) }
    it { is_expected.to include(:id => org.id) }
    it { is_expected.to include(:name => 'Test Org') }
  end
end
