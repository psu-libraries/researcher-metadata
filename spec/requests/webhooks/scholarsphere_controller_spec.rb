# frozen_string_literal: true

require 'requests/requests_spec_helper'

describe Webhooks::ScholarsphereController do
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

  describe 'POST /webhooks/scholarsphere/work_withdrawn' do
    context 'when not given an API key header' do
      it 'returns 401' do
        post webhooks_scholarsphere_work_withdrawn_path

        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when given an API key header with an incorrect key' do
      it 'returns 401' do
        post webhooks_scholarsphere_work_withdrawn_path, headers: { 'X-API-KEY' => 'badkey' }

        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when given an API key header with the correct key' do
      context 'when not given a publication_url param' do
        it 'returns 400' do
          post webhooks_scholarsphere_work_withdrawn_path, headers: { 'X-API-KEY' => 'webhooksecret123' }

          expect(response).to have_http_status :bad_request
        end
      end

      context 'when given a blank publication_url param' do
        it 'returns 400' do
          post(
            webhooks_scholarsphere_work_withdrawn_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { publication_url: '' }
          )

          expect(response).to have_http_status :bad_request
        end
      end

      context 'when given a publication_url param that does not match an existing open access location' do
        it 'returns 404' do
          post(
            webhooks_scholarsphere_work_withdrawn_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { publication_url: 'unknown-url' }
          )

          expect(response).to have_http_status :not_found
        end
      end

      context 'when given a publication_url param that matches an open access location that did not come from ScholarSphere' do
        it 'does not delete the open access location' do
          post(
            webhooks_scholarsphere_work_withdrawn_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { publication_url: 'https://somesite.com/test' }
          )

          expect { upw_oal.reload }.not_to raise_error
        end

        it 'returns 404' do
          post(
            webhooks_scholarsphere_work_withdrawn_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { publication_url: 'https://somesite.com/test' }
          )

          expect(response).to have_http_status :not_found
        end
      end

      context 'when given a publication_url param that matches open access locations that came from ScholarSphere' do
        it 'deletes the matching open access locations' do
          post(
            webhooks_scholarsphere_work_withdrawn_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { publication_url: 'https://scholarsphere.psu.edu/test' }
          )

          expect { ss_oal.reload }.to raise_error ActiveRecord::RecordNotFound
          expect { ss_oal2.reload }.to raise_error ActiveRecord::RecordNotFound
        end

        it 'does not delete non-matching open access locations that came from ScholarSphere' do
          post(
            webhooks_scholarsphere_work_withdrawn_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { publication_url: 'https://scholarsphere.psu.edu/test' }
          )

          expect { ss_oal3.reload }.not_to raise_error
        end

        it 'returns 204' do
          post(
            webhooks_scholarsphere_work_withdrawn_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { publication_url: 'https://scholarsphere.psu.edu/test' }
          )

          expect(response).to have_http_status :no_content
        end
      end
    end
  end

  describe 'POST /webhooks/scholarsphere/open_access_work_published' do
    let!(:deposit) { create(:scholarsphere_work_deposit, draft_scholarsphere_work_deposit_url: '/resources/some-uuid') }

    context 'when not given an API key header' do
      it 'returns 401' do
        post webhooks_scholarsphere_open_access_work_published_path

        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when given an API key header with an incorrect key' do
      it 'returns 401' do
        post webhooks_scholarsphere_open_access_work_published_path, headers: { 'X-API-KEY' => 'badkey' }

        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when given the correct API key' do
      context 'when not given a scholarsphere_work_url param' do
        it 'returns 200 ok' do
          post webhooks_scholarsphere_open_access_work_published_path, headers: { 'X-API-KEY' => 'webhooksecret123' }

          expect(response).to have_http_status :ok
          expect(response.body).to eq 'ok'
        end
      end

      context 'when given a blank scholarsphere_work_url param' do
        it 'returns 200 ok' do
          post(
            webhooks_scholarsphere_open_access_work_published_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { scholarsphere_work_url: '' }
          )

          expect(response).to have_http_status :ok
          expect(response.body).to eq 'ok'
        end
      end

      context 'when given a scholarsphere_work_url that does not match any deposit' do
        it 'returns 200 ok without raising an error' do
          post(
            webhooks_scholarsphere_open_access_work_published_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { scholarsphere_work_url: '/resources/unknown-uuid' }
          )

          expect(response).to have_http_status :ok
          expect(response.body).to eq 'ok'
        end
      end

      context 'when given a scholarsphere_work_url that matches an existing deposit' do
        it 'returns 200 ok' do
          post(
            webhooks_scholarsphere_open_access_work_published_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { scholarsphere_work_url: '/resources/some-uuid' }
          )

          expect(response).to have_http_status :ok
          expect(response.body).to eq 'ok'
        end

        it 'marks the deposit as successful' do
          post(
            webhooks_scholarsphere_open_access_work_published_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { scholarsphere_work_url: '/resources/some-uuid' }
          )

          expect(deposit.reload.status).to eq 'Success'
        end

        it 'creates an OpenAccessLocation for the deposit publication' do
          post(
            webhooks_scholarsphere_open_access_work_published_path,
            headers: { 'X-API-KEY' => 'webhooksecret123' },
            params: { scholarsphere_work_url: '/resources/some-uuid' }
          )

          oal = deposit.publication.open_access_locations.find_by(source: Source::SCHOLARSPHERE)
          expect(oal).to be_present
          expect(oal.url).to eq 'https://scholarsphere.test/resources/some-uuid'
        end
      end
    end
  end
end
