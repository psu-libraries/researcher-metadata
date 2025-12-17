# frozen_string_literal: true

require 'component/component_spec_helper'

describe OAWPreferredPermissionsService do
  let(:service) { described_class.new(doi) }

  before do
    allow(HTTParty).to receive(:get).with('https://bg.api.oa.works/permissions/10.1016%2FS0962-1849%2805%2980014-9')
      .and_return(Rails.root.join('spec', 'fixtures', 'oaw6.json').read)
    allow(HTTParty).to receive(:get).with('https://bg.api.oa.works/permissions/10.1038%2Fs41598-023-28289-6')
      .and_return(Rails.root.join('spec', 'fixtures', 'oaw7.json').read)
    allow(HTTParty).to receive(:get).with('https://bg.api.oa.works/permissions/10.1175%2FJCLI-D-14-00749.1')
      .and_return(Rails.root.join('spec', 'fixtures', 'oaw8.json').read)
    allow(HTTParty).to receive(:get).with('https://bg.api.oa.works/permissions/10.1146%2Fannurev-earth-040610-133408')
      .and_return(Rails.root.join('spec', 'fixtures', 'oaw9.json').read)
    allow(HTTParty).to receive(:get).with('https://bg.api.oa.works/permissions/10.1542%2Fpir.25-11-381')
      .and_return(Rails.root.join('spec', 'fixtures', 'oaw10.json').read)
    allow(HTTParty).to receive(:get).with('https://bg.api.oa.works/permissions/some_unknown_doi')
      .and_return(%{{"all_permissions": []}})
  end

  describe '#preferred_version' do
    context 'when there are only accepted version permissions' do
      let(:doi) { '10.1016/S0962-1849(05)80014-9' }

      it "returns 'acceptedVersion'" do
        expect(service.preferred_version).to eq 'acceptedVersion'
      end
    end

    context 'when there are both accepted and published version permissions and the accepted version has requirements' do
      let(:doi) { '10.1175/JCLI-D-14-00749.1' }

      it "returns 'publishedVersion'" do
        expect(service.preferred_version).to eq 'publishedVersion'
      end
    end

    context 'when there are both accepted and published version permissions with no requirements' do
      let(:doi) { '10.1038/s41598-023-28289-6' }

      it "returns 'Published or Accepted'" do
        expect(service.preferred_version).to eq 'Published or Accepted'
      end
    end

    context 'when there are only submitted version permissions' do
      let(:doi) { '10.1146/annurev-earth-040610-133408' }

      it "returns 'None'" do
        expect(service.preferred_version).to eq 'None'
      end
    end

    context 'when there are no permissions for any version' do
      let(:doi) { '10.1542/pir.25-11-381' }

      it "returns 'None'" do
        expect(service.preferred_version).to eq 'None'
      end
    end

    context 'when the publication is not found in Open Access Button' do
      let(:doi) { 'some_unknown_doi' }

      it 'returns nil' do
        expect(service.preferred_version).to be_nil
      end
    end
  end
end
