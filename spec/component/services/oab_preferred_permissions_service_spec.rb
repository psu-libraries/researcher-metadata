# frozen_string_literal: true

require 'component/component_spec_helper'

describe OABPreferredPermissionsService do
  let(:service) { described_class.new(doi) }

  before do
    allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/permissions/10.1016%2FS0962-1849%2805%2980014-9')
      .and_return(Rails.root.join('spec', 'fixtures', 'oab6.json').read)
    allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/permissions/10.1038%2Fs41598-023-28289-6')
      .and_return(Rails.root.join('spec', 'fixtures', 'oab7.json').read)
  end

  describe '#preferred_permission' do
    context 'when there is only accepted version permissions' do
      let(:doi) { '10.1016/S0962-1849(05)80014-9' }
      let(:response) {
        {
          'can_archive' => true,
          'version' => 'acceptedVersion',
          'versions' => [
            'acceptedVersion',
            'submittedVersion'
          ],
          'embargo_end' => '2024-09-01',
          'licence' => 'cc-by-nc-nd',
          'locations' => [
            'Institutional Repository',
            'Non-commercial Subject Repository'
          ],
          'deposit_statement' => '© This manuscript version is made available under the CC-BY-NC-ND 4.0 license https://creativecommons.org/licenses/by-nc-nd/4.0/',
          'licences' => [
            {
              'type' => 'cc-by-nc-nd'
            }
          ]
        }
      }

      it 'returns the accepted version permission metadata' do
        expect(service.preferred_permission).to eq response
      end
    end

    context 'when there are accepted and published permissions' do
      let(:doi) { '10.1038/s41598-023-28289-6' }
      let(:response) {
        {
          'can_archive' => true,
          'version' => 'publishedVersion',
          'versions' => [
            'publishedVersion'
          ],
          'licence' => 'cc-by',
          'locations' => [
            'institutional repository'
          ],
          'embargo_months' => 0,
          'licences' => [
            {
              'type' => 'CC BY'
            }
          ],
          'deposit_statement' => 'This is a published article.',
          'embargo_end' => '2022-01-24'
        }
      }

      it 'returns the published version permission metadata' do
        expect(service.preferred_permission).to eq response
      end
    end
  end

  describe '#preferred_version' do
    context 'when there is only accepted version permissions' do
      let(:doi) { '10.1016/S0962-1849(05)80014-9' }

      it 'returns the preferred version string' do
        expect(service.preferred_version).to eq 'acceptedVersion'
      end
    end

    context 'when there are accepted and published permissions' do
      let(:doi) { '10.1038/s41598-023-28289-6' }

      it 'returns the preferred version string' do
        expect(service.preferred_version).to eq 'publishedVersion'
      end
    end
  end
end
