# frozen_string_literal: true

require 'component/component_spec_helper'

describe OabBestPermissionsService do
  let(:service) { described_class.new(doi) }
  let(:doi) { '10.1016/S0962-1849(05)80014-9' }

  before do
    allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/permissions/10.1016%2FS0962-1849%2805%2980014-9')
      .and_return(Rails.root.join('spec', 'fixtures', 'oab6.json').read)
  end

  describe '#best_permission' do
    let(:response) {
      { 'can_archive' => true,
        'deposit_statement' => '© This manuscript version is made available under the CC-BY-NC-ND 4.0 license https://creativecommons.org/licenses/by-nc-nd/4.0/',
        'embargo_end' => '2024-09-01',
        'licence' => 'cc-by-nc-nd',
        'licences' => [{ 'type' => 'cc-by-nc-nd' }],
        'locations' => ['Institutional Repository', 'Non-commercial Subject Repository'],
        'version' => 'acceptedVersion',
        'versions' => ['acceptedVersion', 'submittedVersion'] }
    }

    it 'returns the best permission metadata' do
      expect(service.best_permission).to eq response
    end
  end

  describe '#best_version' do
    it 'returns the preferred version string' do
      expect(service.best_version).to eq 'acceptedVersion'
    end
  end

  describe '#set_statement' do
    it 'returns the set_statement string' do
      expect(service.set_statement).to eq '© This manuscript version is made available under the CC-BY-NC-ND 4.0 license https://creativecommons.org/licenses/by-nc-nd/4.0/'
    end
  end

  describe '#embargo_end_date' do
    it 'returns the embargo_end_date data' do
      expect(service.embargo_end_date).to eq Date.parse('2024-09-01', '%Y-%m-%d')
    end
  end

  describe '#licence' do
    it 'returns the licence string' do
      expect(service.licence).to eq 'https://creativecommons.org/licenses/by-nc-nd/4.0/'
    end
  end
end
