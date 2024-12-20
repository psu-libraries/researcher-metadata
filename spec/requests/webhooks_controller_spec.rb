# frozen_string_literal: true

require 'requests/requests_spec_helper'

describe WebhooksController do
  let!(:ss_oal) {
    create(
      :open_access_location,
      source: Source::SCHOLARSPHERE,
      url: 'https://scholarsphere.psu.edu/test'
    )
  }

  let!(:ss_oal2) {
    create(
      :open_access_location,
      source: Source::SCHOLARSPHERE,
      url: 'https://scholarsphere.psu.edu/test'
    )
  }

  let!(:ss_oal3) {
    create(
      :open_access_location,
      source: Source::SCHOLARSPHERE,
      url: 'https://scholarsphere.psu.edu/test2'
    )
  }

  let!(:upw_oal) {
    create(
      :open_access_location,
      source: Source::UNPAYWALL,
      url: 'https://somesite.com/test'
    )
  }

  describe 'POST /webhooks/scholarsphere_events' do
    context 'when not given an API key header' do
      it 'returns 401' do
        post scholarsphere_events_webhook_path

        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when given an API key header with an incorrect key' do
      it 'returns 401' do
        post scholarsphere_events_webhook_path, headers: { 'X-API-KEY' => 'badkey' }

        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when given an API key header with the correct key' do
      context 'when not given a publication_url param' do
        it 'returns 400' do
          post scholarsphere_events_webhook_path, headers: { 'X-API-KEY' => 'webhooksecret123' }

          expect(response).to have_http_status :bad_request
        end
      end

      context 'when given a blank publication_url param' do
        it 'returns 400' do
          post(
            scholarsphere_events_webhook_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { publication_url: '' }
          )

          expect(response).to have_http_status :bad_request
        end
      end

      context 'when given a publication_url param that does not match an existing open access location' do
        it 'returns 404' do
          post(
            scholarsphere_events_webhook_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { publication_url: 'unknown-url' }
          )

          expect(response).to have_http_status :not_found
        end
      end

      context 'when given a publication_url param that matches an open access location that did not come from ScholarSphere' do
        it 'does not delete the open access location' do
          post(
            scholarsphere_events_webhook_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { publication_url: 'https://somesite.com/test' }
          )

          expect { upw_oal.reload }.not_to raise_error
        end

        it 'returns 404' do
          post(
            scholarsphere_events_webhook_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { publication_url: 'https://somesite.com/test' }
          )

          expect(response).to have_http_status :not_found
        end
      end

      context 'when given a publication_url param that matches open access locations that came from ScholarSphere' do
        it 'deletes the matching open access locations' do
          post(
            scholarsphere_events_webhook_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { publication_url: 'https://scholarsphere.psu.edu/test' }
          )

          expect { ss_oal.reload }.to raise_error ActiveRecord::RecordNotFound
          expect { ss_oal2.reload }.to raise_error ActiveRecord::RecordNotFound
        end

        it 'does not delete non-matching open access locations that came from ScholarSphere' do
          post(
            scholarsphere_events_webhook_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { publication_url: 'https://scholarsphere.psu.edu/test' }
          )

          expect { ss_oal3.reload }.not_to raise_error
        end

        it 'returns 204' do
          post(
            scholarsphere_events_webhook_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { publication_url: 'https://scholarsphere.psu.edu/test' }
          )

          expect(response).to have_http_status :no_content
        end
      end
    end
  end
end
