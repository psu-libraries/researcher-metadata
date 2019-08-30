require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/models/wos_contributor'
require_relative '../../../app/models/wos_author_name'

describe WOSContributor do
  let(:parsed_contributor) { double 'parsed contributor' }
  let(:wc) { WOSContributor.new(parsed_contributor) }

  describe '#name' do
    let(:full_name) { double 'full name element', text: "Full Name" }
    let(:wos_name) { double 'web of science name' }
    before do
      allow(parsed_contributor).to receive(:css).with('name[role="researcher_id"] > full_name').and_return(full_name)
      allow(WOSAuthorName).to receive(:new).with("Full Name").and_return wos_name
    end
    it "returns the name of the contributor" do
      expect(wc.name).to eq wos_name
    end
  end

  describe '#orcid' do
    let(:name) { double 'name' }
    before do
      allow(parsed_contributor).to receive(:css).with('name[role="researcher_id"]').and_return name
      allow(name).to receive(:attribute).with('orcid_id').and_return orcid_attr
    end

    context "when the contributor has an ORCID ID" do
      let(:orcid_attr) { double 'orcid attribute', value: "  \n\n ORCID   \n" }

      it "returns the contributor's ORCID ID with any surrounding whitespace removed" do
        expect(wc.orcid).to eq "ORCID"
      end
    end

    context "when the contributor does not have an ORCID ID" do
      let(:orcid_attr) { nil }

      it "returns nil" do
        expect(wc.orcid).to eq nil
      end
    end
  end
end
