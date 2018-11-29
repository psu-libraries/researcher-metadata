require 'component/component_spec_helper'

describe API::V1::OrganizationMembershipSerializer do
  let(:org) { create :organization,
                     name: 'Test Org',
                     organization_type: 'College' }
  let!(:membership) { create :user_organization_membership,
                             user: create(:user),
                             organization: org,
                             position_title: 'Professor',
                             started_on: Date.new(2000, 1, 1),
                             ended_on: Date.new(2001, 2, 2) }

  describe "data attributes" do
    subject { serialized_data_attributes(membership) }
    it { is_expected.to include(:organization_name => 'Test Org') }
    it { is_expected.to include(:organization_type => 'College') }
    it { is_expected.to include(:position_title => 'Professor') }
    it { is_expected.to include(:position_started_on => Date.new(2000, 1, 1)) }
    it { is_expected.to include(:position_ended_on => Date.new(2001, 2, 2)) }
  end
end
