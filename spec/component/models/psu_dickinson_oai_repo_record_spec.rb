# frozen_string_literal: true

require 'component/component_spec_helper'

describe PSUDickinsonOAIRepoRecord do
  let(:psu_rr) { described_class.new(record) }
  let(:record) { double 'fieldhand record', metadata: metadata_xml_fixture, header: header }
  let(:metadata_xml_fixture) { Rails.root.join('spec', 'fixtures', 'oai_record_metadata.xml').read }
  let(:header) { double 'fieldhand header', identifier: 'the-identifier', datestamp: Time.new(2013, 11, 20, 13, 33, 11, 0) }

  let(:creator1) { double 'creator', user_match: um1, ambiguous_user_matches: aum1 }
  let(:creator2) { double 'creator', user_match: um2, ambiguous_user_matches: aum2 }

  let(:um1) { nil }
  let(:aum1) { [] }
  let(:um2) { nil }
  let(:aum2) { [] }

  before do
    allow(PSUDickinsonOAICreator).to receive(:new).with('Testington, Allie').and_return(creator1)
    allow(PSUDickinsonOAICreator).to receive(:new).with('Testworth, Roger').and_return(creator2)
  end

  describe '#title' do
    it 'returns the value of the title attribute from the given metadata object' do
      expect(psu_rr.title).to eq 'Test Law Article'
    end
  end

  describe '#description' do
    it 'returns the value of the discription attribute from the given metadata object' do
      expect(psu_rr.description).to eq 'This is a description of the article.'
    end
  end

  describe '#date' do
    it 'returns the timestamp of the date attribute from the given metadata object' do
      expect(psu_rr.date).to eq '2012-04-23T02:31:14Z'
    end
  end

  describe '#publisher' do
    it 'returns the value of the publisher attribute from the given metadata object' do
      expect(psu_rr.publisher).to eq 'The Publisher'
    end
  end

  describe '#url' do
    it 'returns the value of the identifier attribute from the given metadata object' do
      expect(psu_rr.url).to eq 'https://insight.dickinsonlaw.psu.edu/abc/etc/etc'
    end
  end

  describe '#creators' do
    it 'returns a creator each creator in the given metadtata' do
      expect(psu_rr.creators).to eq [creator1, creator2]
    end
  end

  describe '#identifier' do
    it "returns the identifier from the given metadata object's header" do
      expect(psu_rr.identifier).to eq 'the-identifier'
    end
  end

  describe '#source' do
    it 'returns the value of the source attribute from the given metadata object' do
      expect(psu_rr.source).to eq 'Article Source'
    end
  end

  describe '#any_user_matches?' do
    context 'when none of the creators from the given metadata match any users' do
      it 'returns false' do
        expect(psu_rr.any_user_matches?).to be false
      end
    end

    context 'when one of the creators from the given metadata matches a user' do
      let(:um2) { double 'user' }

      it 'returns true' do
        expect(psu_rr.any_user_matches?).to be true
      end
    end

    context 'when one of the creators from the given metadata matches more than one user' do
      let(:aum2) { [double('user1'), double('user2')] }

      it 'returns true' do
        expect(psu_rr.any_user_matches?).to be true
      end
    end

    context 'when the source attribute does not exists in the given metadata' do
      let(:metadata_xml_fixture) { Rails.root.join('spec', 'fixtures', 'oai_record_metadata8.xml').read }

      describe '#source' do
        it 'returns nil as the source value' do
          expect(psu_rr.source).to be_nil
        end
      end
    end
  end
end
