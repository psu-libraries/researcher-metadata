require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/models/wos_grant'

describe WOSGrant do
  let(:parsed_grant) { double 'parsed_grant' }
  let(:grant) { WOSGrant.new(parsed_grant) }

  describe '#wos_agency' do
    before { allow(parsed_grant).to receive(:css).with('grant_agency').and_return(agency_element) }
    let(:agency_element) { double 'agency', text: "  \n  National Science Foundation\n  " }

    it "returns the name of the grant agency with any surrounding whitespace removed" do
      expect(grant.wos_agency).to eq "National Science Foundation"
    end
  end

  describe '#ids' do
    let(:id1) { double 'grant ID 1', text: "  \n  grant ID 1    \n" }
    let(:id2) { double 'grant ID 2', text: "\n  grant ID 2  \n  " }
    before { allow(parsed_grant).to receive(:css).with('grant_ids > grant_id').and_return [id1, id2] }

    it "returns an array of the IDs for the grant with any surrounding whitespace removed" do
      expect(grant.ids).to eq ["grant ID 1", "grant ID 2"]
    end
  end
end
