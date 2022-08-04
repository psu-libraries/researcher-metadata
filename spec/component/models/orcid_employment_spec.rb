# frozen_string_literal: true

require 'component/component_spec_helper'

describe OrcidEmployment do
  subject(:employment) { described_class.new(membership) }

  let(:membership) { double 'user organization membership',
                            user: user,
                            organization_name: 'Test Organization',
                            position_title: 'Test Title',
                            started_on: Date.new(1999, 12, 31) }
  let(:user) { double 'user', orcid_access_token: 'the orcid token',
                              authenticated_orcid_identifier: 'the orcid id' }

  describe '#to_json' do
    context 'when the given organization membership has an end date' do
      before { allow(membership).to receive(:ended_on).and_return(Date.new(2020, 1, 2)) }

      it 'returns a JSON representation of an ORCID employment that includes an end date' do
        expect(employment.to_json).to eq ({
          organization: {
            name: 'The Pennsylvania State University',
            address: {
              city: 'University Park',
              region: 'Pennsylvania',
              country: 'US'
            },
            'disambiguated-organization': {
              'disambiguated-organization-identifier': 'grid.29857.31',
              'disambiguation-source': 'GRID'
            }
          },
          'department-name': 'Test Organization',
          'role-title': 'Test Title',
          'start-date': {
            year: 1999,
            month: 12,
            day: 31
          },
          'end-date': {
            year: 2020,
            month: 1,
            day: 2
          }
        }.to_json)
      end
    end

    context 'when the given organization membership does not have an end date' do
      before { allow(membership).to receive(:ended_on).and_return(nil) }

      it 'returns a JSON representation of an ORCID employment that does not include an end date' do
        expect(employment.to_json).to eq ({
          organization: {
            name: 'The Pennsylvania State University',
            address: {
              city: 'University Park',
              region: 'Pennsylvania',
              country: 'US'
            },
            'disambiguated-organization': {
              'disambiguated-organization-identifier': 'grid.29857.31',
              'disambiguation-source': 'GRID'
            }
          },
          'department-name': 'Test Organization',
          'role-title': 'Test Title',
          'start-date': {
            year: 1999,
            month: 12,
            day: 31
          }
        }.to_json)
      end
    end
  end

  describe '#orcid_type' do
    it "returns 'employment'" do
      expect(employment.orcid_type).to eq 'employment'
    end
  end
end
