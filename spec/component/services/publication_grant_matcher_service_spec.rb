# frozen_string_literal: true

require 'component/component_spec_helper'

describe PublicationGrantMatcherService do
  describe '#match_from_pure' do
    let(:service) { described_class.new }
    let(:pub) { create(:publication) }

    context 'when the given funding data is nil' do
      it 'does not create any ResearchFund records' do
        expect { service.match_from_pure(nil, pub) }.not_to change(ResearchFund, :count)
      end
    end

    context 'when the given funding data is present' do
      let(:funding_data) do
        [
          {
            'fundingOrganizationAcronym' => 'NSF',
            'fundingNumbers' => ['12345', '54321']
          },
          {
            'fundingOrganizationAcronym' => 'NIMH',
            'fundingNumbers' => ['67890']
          }
        ]
      end
      let(:grant1) { create(:grant) }
      let(:grant2) { create(:grant) }

      before do
        allow(Grant).to receive(:find_by_acronym).with('NSF', '12345').and_return grant1
        allow(Grant).to receive(:find_by_acronym).with('NSF', '54321').and_return grant2
        allow(Grant).to receive(:find_by_acronym).with('NIMH', '67890').and_return nil
      end

      it 'creates a ResearchFund record for each grant found in the database matching the given funding data' do
        expect { service.match_from_pure(funding_data, pub) }.to change(ResearchFund, :count).by 2

        rf = ResearchFund.last
        expect(rf.publication).to eq pub
        expect(rf.grant).to eq grant2
        expect(pub.grants).to contain_exactly(grant1, grant2)
      end

      it 'does not create duplicate ResearchFund records if a matching record already exists for the given publication and grant' do
        ResearchFund.create!(publication: pub, grant: grant1)
        ResearchFund.create!(publication: pub, grant: grant2)

        expect { service.match_from_pure(funding_data, pub) }.not_to change(ResearchFund, :count)
      end
    end
  end
end
