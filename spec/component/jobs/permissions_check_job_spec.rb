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
    let!(:file1) { create(:activity_insight_oa_file, publication: publication, version: 'acceptedVersion') }
    let!(:file2) { create(:activity_insight_oa_file, publication: publication, version: 'publishedVersion') }

    before do
      allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/permissions/10.1016%2FS0962-1849%2805%2980014-9')
        .and_return(Rails.root.join('spec', 'fixtures', 'oab6.json').read)
    end

    context 'when the preferred version is the correct version' do
      it 'updates the publication permissions' do
        job.perform_now(file1.id)
        expect(publication.reload.permissions_last_checked_at).to be_within(1.minute).of(Time.zone.now)
        expect(publication.reload.preferred_version).to eq 'acceptedVersion'
        expect(publication.reload.set_statement).to eq '© This manuscript version is made available under the CC-BY-NC-ND 4.0 license https://creativecommons.org/licenses/by-nc-nd/4.0/'
        expect(publication.reload.licence).to eq 'https://creativecommons.org/licenses/by-nc-nd/4.0/'
      end
    end

    context 'when the preferred version is not the correct version' do
      it 'does not update the publication permissions' do
        job.perform_now(file2.id)
        expect(publication.reload.permissions_last_checked_at).to be_within(1.minute).of(Time.zone.now)
        expect(publication.reload.set_statement).to be_nil
        expect(publication.reload.licence).to be_nil
      end
    end
  end
end
