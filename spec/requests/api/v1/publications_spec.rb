# frozen_string_literal: true

require 'requests/requests_spec_helper'

describe 'API::V1 Publications' do
  describe 'GET /v1/publications' do
    def query_pubs
      get "/v1/publications#{params}", headers: { "X-API-Key": 'token123' }
    end

    context 'when no authorization header is included in the request' do
      it 'returns 401 Unauthorized' do
        get '/v1/publications'
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when an invalid authorization header value is included in the request' do
      it 'returns 401 Unauthorized' do
        get '/v1/publications', headers: { "X-API-Key": 'bad-token' }
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when a valid authorization header value is included in the request' do
      let!(:publications) { create_list(:publication, 10, visible: true) }
      let!(:invisible_pub) { create(:publication, visible: false) }
      let!(:inaccessible_pub) { create(:publication, visible: true) }
      let(:params) { '' }
      let!(:token) { create :api_token, token: 'token123', total_requests: 0, last_used_at: nil }
      let(:org) { create :organization }
      let(:user) { create :user }

      before do
        publications.each { |p| create :authorship, publication: p, user: user }
        create :user_organization_membership, user: user, organization: org
        create :organization_api_permission, organization: org, api_token: token
      end

      describe 'with no provided params:' do
        before do
          query_pubs
        end

        it 'returns HTTP status 200' do
          expect(response).to have_http_status :ok
        end

        it 'returns all visible publications to which the given API token has access' do
          expect(json_response[:data].size).to eq(10)
        end

        it 'updates the usage statistics on the API token' do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end
      end

      describe 'params:' do
        describe 'activity_insight_id' do
          let(:ai_pub) { create(:publication, visible: true, imports: [pub_import]) }
          let(:pub_import) { create(:publication_import, source: 'Activity Insight', source_identifier: '123') }

          before do
            create :authorship, user: user, publication: ai_pub
            query_pubs
          end

          context 'with a valid Activity Insight ID' do
            let(:params) { '?activity_insight_id=123' }

            it 'returns a publication matching the specified Activity Insight ID' do
              expect(json_response[:data].size).to eq(1)
              expect(json_response[:data].first[:attributes][:activity_insight_ids].size).to eq(1)
              expect(json_response[:data].first[:attributes][:activity_insight_ids].first).to eq('123')
            end
          end

          context 'with an invalid Activity Insight ID' do
            let(:params) { '?activity_insight_id=lol' }

            it 'returns no results' do
              expect(json_response[:data].size).to eq(0)
            end
          end
        end

        describe 'doi' do
          let(:doi_pub) { create(:publication, visible: true, doi: 'https://doi.org/10.26207/46a7-9981') }

          before do
            create :authorship, user: user, publication: doi_pub
            query_pubs
          end

          context 'with a full DOI URL' do
            let(:params) { '?doi=https://doi.org/10.26207/46a7-9981' }

            it 'returns a publication matching the specified DOI' do
              expect(json_response[:data].size).to eq(1)
              expect(json_response[:data].first[:attributes][:doi]).to eq('https://doi.org/10.26207/46a7-9981')
            end
          end

          context 'with a DOI starting with the doi: prefix' do
            let(:params) { '?doi=doi:10.26207/46a7-9981' }

            it 'returns a publication matching the specified DOI' do
              expect(json_response[:data].size).to eq(1)
              expect(json_response[:data].first[:attributes][:doi]).to eq('https://doi.org/10.26207/46a7-9981')
            end
          end

          context 'with a DOI with no prefix' do
            let(:params) { '?doi=10.26207/46a7-9981' }

            it 'returns a publication matching the specified DOI' do
              expect(json_response[:data].size).to eq(1)
              expect(json_response[:data].first[:attributes][:doi]).to eq('https://doi.org/10.26207/46a7-9981')
            end
          end

          context 'with an invalid DOI' do
            let(:params) { '?doi=lol' }

            it 'returns no results' do
              expect(json_response[:data].size).to eq(0)
            end
          end
        end

        describe 'limit' do
          let(:params) { '?limit=5' }

          before do
            query_pubs
          end

          it 'returns the specified number of publications' do
            expect(json_response[:data].size).to eq(5)
          end
        end
      end
    end
  end

  describe 'PATCH /v1/publications' do
    context 'when no authorization header is included in the request' do
      it 'returns 401 Unauthorized' do
        patch '/v1/publications'
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when an invalid authorization header value is included in the request' do
      before do
        create :api_token, token: 'token123'
      end

      it 'returns 401 Unauthorized' do
        patch '/v1/publications', headers: { "X-API-Key": 'bad-token' }
        expect(response).to have_http_status :unauthorized
      end

      it 'returns 401 Unauthorized when the provided token does not have write access' do
        patch '/v1/publications', headers: { "X-API-Key": 'token123' }
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when a valid authorization header value is included in the request' do
      context 'with invalid request params missing url' do
        before do
          create :api_token, token: 'token123', write_access: true

          patch '/v1/publications',
                headers: { "X-API-Key": 'token123' },
                params: {
                  some_key: 'some_value'
                }
        end

        it 'returns HTTP status 422' do
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'returns the invalid params missing url message' do
          expect(json_response).to include(code: 422, message: I18n.t('api.publications.patch.params_missing_url'))
        end
      end

      context 'with invalid request params missing ids' do
        before do
          create :api_token, token: 'token123', write_access: true

          patch '/v1/publications',
                headers: { "X-API-Key": 'token123' },
                params: {
                  scholarsphere_open_access_url: 'new_url',
                  some_key: 'some_value'
                }
        end

        it 'returns HTTP status 422' do
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'returns the invalid params missing ids message' do
          expect(json_response).to include(code: 422, message: I18n.t('api.publications.patch.params_missing_id'))
        end
      end

      context 'with invalid request both ids provided' do
        before do
          create :api_token, token: 'token123', write_access: true

          patch '/v1/publications',
                headers: { "X-API-Key": 'token123' },
                params: {
                  scholarsphere_open_access_url: 'new_url',
                  doi: '123',
                  activity_insight_id: '123'
                }
        end

        it 'returns HTTP status 422' do
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'returns the invalid params both ids provided message' do
          expect(json_response).to include(code: 422, message: I18n.t('api.publications.patch.params_both_ids'))
        end
      end

      context 'when valid request params: an activity insight id and a url' do
        let(:activity_insight_id) { '123' }
        let(:publication) { create :publication, open_access_locations: open_access_locations }

        before do
          create :api_token, token: 'token123', write_access: true
          create :publication_import, source: 'Activity Insight', source_identifier: '123', publication: publication

          patch '/v1/publications',
                params: {
                  activity_insight_id: activity_insight_id,
                  scholarsphere_open_access_url: scholarsphere_open_access_url
                },
                headers: { "X-API-Key": 'token123' }
        end

        context 'with a new open access location' do
          let(:scholarsphere_open_access_url) { 'new_url' }
          let(:open_access_locations) { [build(:open_access_location, source: Source::SCHOLARSPHERE, url: 'existing_url')] }

          it 'returns HTTP status 200' do
            expect(response).to have_http_status :ok
          end

          it 'returns the success message' do
            expect(json_response).to include(code: 200, message: I18n.t('api.publications.patch.success'))
          end
        end

        context 'with an existing open access location' do
          let(:scholarsphere_open_access_url) { 'existing_url' }
          let(:open_access_locations) { [build(:open_access_location, source: Source::SCHOLARSPHERE, url: 'existing_url')] }

          it 'returns HTTP status 422' do
            expect(response).to have_http_status :unprocessable_entity
          end

          it 'returns the success message' do
            expect(json_response).to include(code: 422, message: I18n.t('api.publications.patch.existing_location'))
          end
        end

        context 'when no publications found' do
          let(:activity_insight_id) { 'non_existing_id' }
          let(:scholarsphere_open_access_url) { 'new_url' }
          let(:open_access_locations) { [build(:open_access_location, source: Source::SCHOLARSPHERE, url: 'existing_url')] }

          it 'returns HTTP status 404' do
            expect(response).to have_http_status :not_found
          end

          it 'returns the existing location message' do
            expect(json_response).to include(code: 404, message: I18n.t('api.publications.patch.no_content'))
          end
        end
      end

      context 'when valid request params: a doi and a url' do
        def request_with_doi
          patch '/v1/publications',
                params: {
                  doi: doi,
                  scholarsphere_open_access_url: scholarsphere_open_access_url
                },
                headers: { "X-API-Key": 'token123' }
        end

        let(:doi) { 'https://doi.org/10.26207/46a7-9981' }

        before do
          create :api_token, token: 'token123', write_access: true
        end

        context 'with a new open access location' do
          let(:scholarsphere_open_access_url) { 'new_url' }

          before do
            create_list(:publication, 5, doi: doi)
            request_with_doi
          end

          it 'returns HTTP status 200' do
            expect(response).to have_http_status :ok
          end

          it 'returns the success message' do
            expect(json_response).to include(code: 200, message: I18n.t('api.publications.patch.success'))
          end
        end

        context 'with an existing open access location' do
          let(:scholarsphere_open_access_url) { 'existing_url' }
          let(:open_access_locations) { [build(:open_access_location, source: Source::SCHOLARSPHERE, url: 'existing_url')] }

          before do
            create :publication, doi: doi, open_access_locations: open_access_locations
            request_with_doi
          end

          it 'returns HTTP status 422' do
            expect(response).to have_http_status :unprocessable_entity
          end

          it 'returns the existing location message' do
            expect(json_response).to include(code: 422, message: I18n.t('api.publications.patch.existing_location'))
          end
        end

        context 'when no publications found' do
          let(:doi) { 'non_existing_doi' }
          let(:scholarsphere_open_access_url) { 'new_url' }
          let(:publication_import) {}

          before do
            request_with_doi
          end

          it 'returns HTTP status 404' do
            expect(response).to have_http_status :not_found
          end

          it 'returns the existing location message' do
            expect(json_response).to include(code: 404, message: I18n.t('api.publications.patch.no_content'))
          end
        end
      end
    end
  end

  describe 'GET /v1/publications/:id' do
    let!(:pub) { create :publication,
                        title: 'requested publication',
                        visible: visible }
    let!(:inaccessible_pub) { create :publication, visible: true }
    let!(:token) { create :api_token,
                          token: 'token123',
                          total_requests: 0,
                          last_used_at: nil }
    let(:visible) { true }
    let(:org) { create :organization }
    let(:user) { create :user }

    before do
      create :organization_api_permission, organization: org, api_token: token
      create :user_organization_membership, organization: org, user: user
      create :authorship, user: user, publication: pub
    end

    context 'when no authorization header is included in the request' do
      it 'returns 401 Unauthorized' do
        get "/v1/publications/#{pub.id}"
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when an invalid authorization header value is included in the request' do
      it 'returns 401 Unauthorized' do
        get "/v1/publications/#{pub.id}", headers: { "X-API-Key": 'bad-token' }
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when a valid authorization header value is included in the request' do
      context 'when requesting a visible publication' do
        before do
          get "/v1/publications/#{pub.id}", headers: { "X-API-Key": 'token123' }
        end

        it 'returns HTTP status 200' do
          expect(response).to have_http_status :ok
        end

        it 'returns the requested publication' do
          expect(
            json_response[:data][:attributes][:title]
          ).to eq 'requested publication'
        end

        it 'updates the usage statistics on the API token' do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end
      end

      context 'when requesting an invisible publication' do
        let(:visible) { false }

        before do
          get "/v1/publications/#{pub.id}", headers: { "X-API-Key": 'token123' }
        end

        it 'returns HTTP status 404' do
          expect(response).to have_http_status :not_found
        end
      end

      context 'when requesting an inaccessible publication' do
        before do
          get "/v1/publications/#{inaccessible_pub.id}", headers: { "X-API-Key": 'token123' }
        end

        it 'returns HTTP status 404' do
          expect(response).to have_http_status :not_found
        end
      end
    end
  end

  describe 'GET /v1/publications/:id/grants' do
    let!(:pub) { create :publication, visible: visible }
    let!(:inaccessible_pub) { create :publication, visible: true }
    let!(:token) { create :api_token,
                          token: 'token123',
                          total_requests: 0,
                          last_used_at: nil }
    let(:visible) { true }
    let(:org) { create :organization }
    let(:user) { create :user }
    let(:g1) { create :grant }
    let(:g2) { create :grant }

    before do
      create :organization_api_permission, organization: org, api_token: token
      create :user_organization_membership, organization: org, user: user
      create :authorship, user: user, publication: pub
      create :research_fund, publication: pub, grant: g1
      create :research_fund, publication: pub, grant: g2
    end

    context 'when no authorization header is included in the request' do
      it 'returns 401 Unauthorized' do
        get "/v1/publications/#{pub.id}/grants"
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when an invalid authorization header value is included in the request' do
      it 'returns 401 Unauthorized' do
        get "/v1/publications/#{pub.id}/grants", headers: { "X-API-Key": 'bad-token' }
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when a valid authorization header value is included in the request' do
      context 'when requesting grants for a visible publication' do
        before do
          get "/v1/publications/#{pub.id}/grants", headers: { "X-API-Key": 'token123' }
        end

        it 'returns HTTP status 200' do
          expect(response).to have_http_status :ok
        end

        it 'returns the grants for the given publication' do
          expect(json_response[:data].size).to eq(2)
          expect(json_response[:data].find { |grant| grant[:id] == g1.id.to_s && grant[:type] == 'grant' }).not_to be_nil
          expect(json_response[:data].find { |grant| grant[:id] == g2.id.to_s && grant[:type] == 'grant' }).not_to be_nil
        end

        it 'updates the usage statistics on the API token' do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end
      end

      context 'when requesting an invisible publication' do
        let(:visible) { false }

        before do
          get "/v1/publications/#{pub.id}/grants", headers: { "X-API-Key": 'token123' }
        end

        it 'returns HTTP status 404' do
          expect(response).to have_http_status :not_found
        end

        it 'updates the usage statistics on the API token' do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end
      end

      context 'when requesting an inaccessible publication' do
        before do
          get "/v1/publications/#{inaccessible_pub.id}/grants", headers: { "X-API-Key": 'token123' }
        end

        it 'returns HTTP status 404' do
          expect(response).to have_http_status :not_found
        end

        it 'updates the usage statistics on the API token' do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end
      end
    end
  end
end
