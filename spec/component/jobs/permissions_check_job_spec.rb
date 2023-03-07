# frozen_string_literal: true

require 'component/component_spec_helper'

describe PermissionsCheckJob, type: :job do
  let(:job) { described_class }

  describe '.perform_later' do
    ActiveJob::Base.queue_adapter = :test
    it 'enqueues a job' do
      expect { job.perform_later(1) }.to have_enqueued_job.with(1).on_queue('default')
    end
  end

  describe '#perform_now' do
    let!(:publication) { create(:publication,
                                doi: 'https://doi.org/10.1016/S0962-1849(05)80014-9')}

    before do
      allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/permissions/10.1016%2FS0962-1849%2805%2980014-9')
        .and_return(Rails.root.join('spec', 'fixtures', 'oab6.json').read)
    end

    it 'updates the publication permissions' do
      job.perform_now(publication.id)
      expect(publication.reload.preferred_version).to eq 'acceptedVersion'
      expect(publication.reload.set_statement).to eq '© This manuscript version is made available under the CC-BY-NC-ND 4.0 license https://creativecommons.org/licenses/by-nc-nd/4.0/'
      expect(publication.reload.licence).to eq 'https://creativecommons.org/licenses/by-nc-nd/4.0/'
    end
  end
end
