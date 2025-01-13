# frozen_string_literal: true

require 'component/component_spec_helper'

describe FilePermissionsCheckJob, type: :job do
  let(:job) { described_class }

  describe '.perform_later' do
    ActiveJob::Base.queue_adapter = :test
    it 'enqueues a job' do
      expect { job.perform_later(1) }.to have_enqueued_job.with(1).on_queue('default')
    end
  end

  describe '#perform_now' do
    let!(:pub) {
      create(
        :publication,
        doi: 'https://doi.org/10.1016/S0962-1849(05)80014-9'
      )
    }
    let!(:file) {
      create(
        :activity_insight_oa_file,
        publication: pub,
        version: version
      )
    }

    context 'when OAB returns a license' do
      before do
        allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/permissions/10.1016%2FS0962-1849%2805%2980014-9')
          .and_return(Rails.root.join('spec', 'fixtures', 'oab7.json').read)
      end

      context "when the file's version is acceptedVersion" do
        let(:version) { 'acceptedVersion' }

        it "updates the file's permissions fields with the correct metadata for the accepted version" do
          job.perform_now(file.id)

          f = file.reload
          expect(f.license).to eq 'https://rightsstatements.org/page/InC/1.0/'
          expect(f.set_statement).to eq(
            'This version of the article has been accepted for publication, after peer review (when applicable) ' +
            'and is subject to Springer Nature’s AM terms of use, but is not the Version of Record and does not reflect post-acceptance improvements, or any corrections. The Version of Record is available online at: http://dx.doi.org/10.1038/s41598-023-28289-6'
          )
          expect(f.embargo_date).to eq Date.new(2024, 1, 24)
          expect(f.checked_for_set_statement).to be true
          expect(f.checked_for_embargo_date).to be true
        end
      end

      context "when the file's version is publishedVersion" do
        let(:version) { 'publishedVersion' }

        it "updates the file's permissions fields with the correct metadata for the published version" do
          job.perform_now(file.id)

          f = file.reload
          expect(f.license).to eq 'https://creativecommons.org/licenses/by/4.0/'
          expect(f.set_statement).to eq 'This is a published article.'
          expect(f.embargo_date).to eq Date.new(2022, 1, 24)
          expect(f.checked_for_set_statement).to be true
          expect(f.checked_for_embargo_date).to be true
        end
      end
    end

    context 'when OAB does not return a license' do
      let(:version) { 'acceptedVersion' }

      before do
        allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/permissions/10.1016%2FS0962-1849%2805%2980014-9')
          .and_return(Rails.root.join('spec', 'fixtures', 'oab10.json').read)
      end

      it "updates the file's license field with All rights reserved" do
        job.perform_now(file.id)

        f = file.reload
        expect(f.license).to eq 'https://rightsstatements.org/page/InC/1.0/'
        expect(f.checked_for_set_statement).to be true
        expect(f.checked_for_embargo_date).to be true
      end
    end
  end
end
