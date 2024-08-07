# frozen_string_literal: true

require 'component/component_spec_helper'

describe DOIVerificationJob, type: :job do
  let(:job) { described_class }

  describe '.perform_later' do
    ActiveJob::Base.queue_adapter = :test
    it 'enqueues a job' do
      expect { job.perform_later(1) }.to have_enqueued_job.with(1).on_queue('default')
    end
  end

  describe '#perform_now' do
    let(:publication) { create(:publication,
                               doi: pub_doi,
                               title: pub_title,
                               doi_verified: doi_verified)}
    let(:pub_title) { 'Psychotherapy integration and the need for better theories of change: A rejoinder to Alford' }
    let(:pub_doi) { 'https://doi.org/10.1016/S0962-1849(05)80014-9' }
    let(:doi_verified) { nil }
    let(:response) { instance_double(UnpaywallResponse,
                                     title: 'Psychotherapy integration and the need for better theories of change: A rejoinder to Alford',
                                     matchable_title: 'psychotherapyintegrationandtheneedforbettertheoriesofchangearejoindertoalford',
                                     doi: 'https://doi.org/10.1016/S0962-1849(05)80014-9')}
    let(:empty_response) { instance_double(UnpaywallResponse,
                                           matchable_title: '',
                                           doi: nil)}
    let(:service) { instance_double DOIVerificationService }

    context 'when the publication has a DOI' do
      let(:pub_title) { 'Psychotherapy integration' }

      before { allow(DOIVerificationService).to receive(:new).with(publication).and_return(service) }

      it 'calls the DOI verification service and updates doi verified to false' do
        expect(service).to receive(:verify)
        job.perform_now(publication.id)
      end
    end

    context 'when the publication does not have a DOI' do
      let(:pub_doi) { nil }

      context "when the publication's doi is found in Unpaywall" do
        before { allow(UnpaywallClient).to receive(:query_unpaywall).with(publication).and_return(response) }

        context 'when the publication title and unpaywall title match' do
          before { job.perform_now(publication.id) }

          it 'updates the publication doi' do
            expect(publication.reload.doi).to eq 'https://doi.org/10.1016/S0962-1849(05)80014-9'
          end

          it 'updates the doi verification to true' do
            expect(publication.reload.doi_verified).to be true
          end
        end

        context 'when the publication title and unpaywall title do not match' do
          let(:pub_title) { 'Psychotherapy integration' }

          before { job.perform_now(publication.id) }

          it 'does not update the publication doi' do
            expect(publication.reload.doi).to be_nil
          end

          it 'updates the doi verification to false' do
            expect(publication.reload.doi_verified).to be false
          end
        end
      end

      context "when the publication's doi is not found in Unpaywall" do
        before do
          allow(UnpaywallClient).to receive(:query_unpaywall).with(publication).and_return(empty_response)
          job.perform_now(publication.id)
        end

        it 'does not update the publication doi' do
          expect(publication.reload.doi).to be_nil
        end

        it 'updates the doi verification to false' do
          expect(publication.reload.doi_verified).to be false
        end
      end
    end

    context 'when the publication has already been verified' do
      let(:doi_verified) { true }
      let(:pub_title) { 'Psychotherapy integration' }

      before { job.perform_now(publication.id) }

      it 'does not update the publication' do
        expect(publication.reload.doi_verified).to be true
      end
    end
  end
end
