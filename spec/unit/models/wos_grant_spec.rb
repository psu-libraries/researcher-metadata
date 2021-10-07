require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/models/wos_grant'
require_relative '../../../app/models/wos_grant_id'

describe WOSGrant do
  let(:parsed_grant) { double 'parsed_grant' }
  let(:grant) { WOSGrant.new(parsed_grant) }

  describe '#wos_agency' do
    before { allow(parsed_grant).to receive(:css).with('grant_agency').and_return(agency_element) }

    let(:agency_element) { double 'agency', text: "  \n  National Science Foundation\n  " }

    it 'returns the name of the grant agency with any surrounding whitespace removed' do
      expect(grant.wos_agency).to eq 'National Science Foundation'
    end
  end

  describe '#agency' do
    before { allow(parsed_grant).to receive(:css).with('grant_agency').and_return(agency_element) }

    let(:agency_element) { double 'agency', text: agency_text }

    context "when the agency name in the given data is 'Other Agency'" do
      let(:agency_text) { 'Other Agency' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end

    context "when the agency name in the given data is 'National Science Foundation'" do
      let(:agency_text) { 'National Science Foundation' }

      it "returns 'National Science Foundation'" do
        expect(grant.agency).to eq 'National Science Foundation'
      end
    end

    context "when the agency name in the given data is 'National Science Foundation' with surrounding whitespace" do
      let(:agency_text) { "  \n  National Science Foundation\n  " }

      it "returns 'National Science Foundation'" do
        expect(grant.agency).to eq 'National Science Foundation'
      end
    end

    context "when the agency name in the given data is 'national science foundation'" do
      let(:agency_text) { 'national science foundation' }

      it "returns 'National Science Foundation'" do
        expect(grant.agency).to eq 'National Science Foundation'
      end
    end

    context "when the agency name in the given data is 'U. S. National Science Foundation'" do
      let(:agency_text) { 'U. S. National Science Foundation' }

      it "returns 'National Science Foundation'" do
        expect(grant.agency).to eq 'National Science Foundation'
      end
    end

    context "when the agency name in the given data is 'NSF'" do
      let(:agency_text) { 'NSF' }

      it "returns 'National Science Foundation'" do
        expect(grant.agency).to eq 'National Science Foundation'
      end
    end

    context "when the agency name in the given data is 'NSF through Penn State Center for Nanoscale Science'" do
      let(:agency_text) { 'NSF through Penn State Center for Nanoscale Science' }

      it "returns 'National Science Foundation'" do
        expect(grant.agency).to eq 'National Science Foundation'
      end
    end

    context "when the agency name in the given data is 'McMurdo LTER, NSF'" do
      let(:agency_text) { 'McMurdo LTER, NSF' }

      it "returns 'National Science Foundation'" do
        expect(grant.agency).to eq 'National Science Foundation'
      end
    end

    context "when the agency name in the given data is 'Chinese NSF'" do
      let(:agency_text) { 'Chinese NSF' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end

    context "when the agency name in the given data is 'NSFC'" do
      let(:agency_text) { 'NSFC' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end

    context "when the agency name in the given data is 'CNSF'" do
      let(:agency_text) { 'CNSF' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end

    context "when the agency name in the given data is 'NSF of China'" do
      let(:agency_text) { 'NSF of China' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end

    context "when the agency name in the given data is 'NSFC'" do
      let(:agency_text) { 'NNSFC' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end

    context "when the agency name in the given data is 'NNSF of China'" do
      let(:agency_text) { 'NNSF of China' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end

    context "when the agency name in the given data is 'National Science Foundation of China'" do
      let(:agency_text) { 'National Science Foundation of China' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end

    context "when the agency name in the given data is 'Swiss National Science Foundation'" do
      let(:agency_text) { 'Swiss National Science Foundation' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end

    context "when the agency name in the given data is 'GNSF'" do
      let(:agency_text) { 'GNSF' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end

    context "when the agency name in the given data is 'SNSF'" do
      let(:agency_text) { 'SNSF' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end

    context "when the agency name in the given data is 'German National Science Foundation'" do
      let(:agency_text) { 'German National Science Foundation' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end

    context "when the agency name in the given data is 'SFFR-NSF'" do
      let(:agency_text) { 'SFFR-NSF' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end

    context "when the agency name in the given data is 'Chinese National Science Foundation'" do
      let(:agency_text) { 'Chinese National Science Foundation' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end

    context "when the agency name in the given data is 'National Science Foundation for Distinguished Young Scholars of China'" do
      let(:agency_text) { 'National Science Foundation for Distinguished Young Scholars of China' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end

    context "when the agency name in the given data is 'China National Science Foundation'" do
      let(:agency_text) { 'China National Science Foundation' }

      it 'returns nil' do
        expect(grant.agency).to eq nil
      end
    end
  end

  describe '#ids' do
    let(:id_element1) { double 'id element 1' }
    let(:id_element2) { double 'id element 2' }
    let(:id1) { double 'id 1' }
    let(:id2) { double 'id 2' }

    before do
      allow(WOSGrantID).to receive(:new).with(grant, id_element1).and_return(id1)
      allow(WOSGrantID).to receive(:new).with(grant, id_element2).and_return(id2)
      allow(parsed_grant).to receive(:css).with('grant_ids > grant_id').and_return([id_element1, id_element2])
    end

    it 'returns an array of the ids associated with the grant' do
      expect(grant.ids).to eq [id1, id2]
    end
  end
end
