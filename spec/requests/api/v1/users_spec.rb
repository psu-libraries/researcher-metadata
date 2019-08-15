require 'requests/requests_spec_helper'

describe 'API::V1 Users' do
  let(:h_index) { nil }
  let(:title) { nil }
  let(:website) { nil }
  let(:bio) { nil }
  let(:room) { nil }
  let(:building) { nil }
  let!(:token) { create :api_token, token: 'token123', total_requests: 0, last_used_at: nil }
  let!(:inaccessible_user) { create :user, webaccess_id: 'inaccessible' }
  let(:org) { create :organization }

  before do
    create :organization_api_permission, api_token: token, organization: org
  end

  describe 'GET /v1/users/:webaccess_id/presentations' do
    let!(:user) { create(:user_with_presentations,
                         webaccess_id: 'xyz321',
                         presentations_count: 10) }
    let!(:invisible_presentation) {
      user.presentations.create(
        activity_insight_identifier: 'abc123',
        visible: false
      )
    }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }
    let(:headers) { { "accept" => "application/json", 'X-API-Key' => 'token123' } }
    let(:user_without_visible_presentations) { create(:user, webaccess_id: "nopres123") }

    before do
      create :user_organization_membership,
             user: user_without_visible_presentations,
             organization: org
      create :user_organization_membership, user: user, organization: org
      get "/v1/users/#{webaccess_id}/presentations#{params}", headers: headers
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
      context "when the user has presentations" do
        it "returns all the user's visible presentations" do
          expect(json_response[:data].size).to eq(10)
        end
      end
      context "when the user has no presentations" do
        let(:webaccess_id) { user_without_visible_presentations.webaccess_id }

        it "returns an empty JSON data hash" do
          expect(json_response[:data].size).to eq(0)
        end
      end
      context "when an html-formatted response is requested" do
        let(:headers) { { "accept" => "text/html", 'X-API-Key' => 'token123' } }
        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end
        it "updates the usage statistics on the API token" do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end
      end
    end
    context "for an invalid webaccess_id" do
      let(:webaccess_id) { "aaa" }
      it "returns 404 not found" do
        expect(response).to have_http_status 404
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
    end
    context "for a webaccess_id of a user that is inaccessible to the given API token" do
      let(:webaccess_id) { "inaccessible" }

      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end

      it "returns 404" do
        expect(response.code).to eq '404'
      end
    end
  end

  describe 'GET /v1/users/:webaccess_id/contracts' do
    let!(:user) { create(:user_with_contracts,
                         webaccess_id: 'xyz321',
                         contracts_count: 10,
                         show_all_contracts: true) }
    let!(:other_user) { create :user, show_all_contracts: false }
    let!(:hidden_contract) { create :contract, visible: true }
    let!(:invisible_contract) { create :contract, visible: false }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }
    let(:headers) { { "accept" => "application/json", 'X-API-Key' => 'token123' } }
    let(:user_without_contracts) { create(:user, webaccess_id: "nocons123") }

    before do
      create :user_organization_membership, user: user, organization: org
      create :user_organization_membership, user: other_user, organization: org
      create :user_organization_membership, user: user_without_contracts, organization: org
      create :user_contract, user: user, contract: invisible_contract
      create :user_contract, user: user, contract: hidden_contract
      create :user_contract, user: other_user, contract: hidden_contract
      get "/v1/users/#{webaccess_id}/contracts#{params}", headers: headers
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
      context "when the user has contracts" do
        it "returns all the user's contracts" do
          expect(json_response[:data].size).to eq(10)
        end
      end
      context "when the user has no contracts" do
        let(:webaccess_id) { user_without_contracts.webaccess_id }
        it "returns an empty JSON data hash" do
          expect(json_response[:data].size).to eq(0)
        end
      end
      context "when an html-formatted response is requested" do
        let(:headers) { { "accept" => "text/html", 'X-API-Key' => 'token123' } }
        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end
        it "updates the usage statistics on the API token" do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end
      end
    end
    context "for an invalid webaccess_id" do
      let(:webaccess_id) { "aaa" }
      it "returns 404 not found" do
        expect(response).to have_http_status 404
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
    end
    context "for a webaccess_id of a user that is inaccessible to the given API token" do
      let(:webaccess_id) { "inaccessible" }

      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end

      it "returns 404" do
        expect(response.code).to eq '404'
      end
    end
  end

  describe 'GET /v1/users/:webaccess_id/news_feed_items' do
    let!(:user) { create(:user_with_news_feed_items, webaccess_id: 'xyz321', news_feed_items_count: 10) }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }
    let(:headers) { { "accept" => "application/json", 'X-API-Key' => 'token123' } }
    let(:user_without_news_feed_items) { create(:user, webaccess_id: "nocons123") }

    before do
      create :user_organization_membership, user: user, organization: org
      create :user_organization_membership, user: user_without_news_feed_items, organization: org
      get "/v1/users/#{webaccess_id}/news_feed_items#{params}", headers: headers
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
      context "when the user has news feed items" do
        it "returns all the user's news feed items" do
          expect(json_response[:data].size).to eq(10)
        end
      end
      context "when the user has no news feed items" do
        let(:webaccess_id) { user_without_news_feed_items.webaccess_id }
        it "returns an empty JSON data hash" do
          expect(json_response[:data].size).to eq(0)
        end
      end
      context "when an html-formatted response is requested" do
        let(:headers) { { "accept" => "text/html", 'X-API-Key' => 'token123' } }
        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end
        it "updates the usage statistics on the API token" do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end
      end
    end
    context "for an invalid webaccess_id" do
      let(:webaccess_id) { "aaa" }
      it "returns 404 not found" do
        expect(response).to have_http_status 404
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
    end
    context "for a webaccess_id of a user that is inaccessible to the given API token" do
      let(:webaccess_id) { "inaccessible" }

      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end

      it "returns 404" do
        expect(response.code).to eq '404'
      end
    end
  end

  describe 'GET /v1/users/:webaccess_id/performances' do
    let!(:user) { create(:user_with_performances,
                         webaccess_id: 'xyz321',
                         performances_count: 10) }
    let!(:hidden_performance) { create :performance, visible: true }
    let!(:invisible_performance) { create :performance, visible: false }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }
    let(:headers) { { "accept" => "application/json", 'X-API-Key' => 'token123' } }
    let(:user_without_performances) { create(:user, webaccess_id: "nopers123") }

    before do
      create :user_organization_membership, user: user, organization: org
      create :user_organization_membership, user: user_without_performances, organization: org
      create :user_performance, user: user, performance: invisible_performance
      create :user_performance, user: user, performance: hidden_performance
      get "/v1/users/#{webaccess_id}/performances#{params}", headers: headers
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      context "when the user has performances" do
        it "returns all the user's performances" do
          expect(json_response[:data].size).to eq(11)
        end
      end
      context "when the user has no performances" do
        let(:webaccess_id) { user_without_performances.webaccess_id }
        it "returns an empty JSON data hash" do
          expect(json_response[:data].size).to eq(0)
        end
      end
      context "when an html-formatted response is requested" do
        let(:headers) { { "accept" => "text/html", 'X-API-Key' => 'token123' } }
        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end
      end
    end
    context "for an invalid webaccess_id" do
      let(:webaccess_id) { "aaa" }
      it "returns 404 not found" do
        expect(response).to have_http_status 404
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
    end
    context "for a webaccess_id of a user that is inaccessible to the given API token" do
      let(:webaccess_id) { "inaccessible" }

      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end

      it "returns 404" do
        expect(response.code).to eq '404'
      end
    end
  end

  describe 'GET /v1/users/:webaccess_id/organization_memberships' do
    let!(:user) { create(:user_with_organization_memberships, webaccess_id: 'xyz321') }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }
    let(:headers) { { "accept" => "application/json", 'X-API-Key' => 'token123' } }

    before do
      create :user_organization_membership, user: user, organization: org
      get "/v1/users/#{webaccess_id}/organization_memberships#{params}", headers: headers
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
      context "when the user has organization memberships" do
        it "returns all the user's organization memberships" do
          expect(json_response[:data].size).to eq(4)
        end
      end
    end
    context "for an invalid webaccess_id" do
      let(:webaccess_id) { "aaa" }
      it "returns 404 not found" do
        expect(response).to have_http_status 404
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
    end
    context "for a webaccess_id of a user that is inaccessible to the given API token" do
      let(:webaccess_id) { "inaccessible" }

      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end

      it "returns 404" do
        expect(response.code).to eq '404'
      end
    end
  end

  describe 'GET /v1/users/:webaccess_id/publications' do
    let!(:user) { create(:user_with_authorships,
                         webaccess_id: 'xyz321',
                         authorships_count: 10,
                         show_all_publications: show_pubs) }
    let!(:invisible_pub) { create :publication, visible: false }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }
    let(:headers) { { "accept" => "application/json", 'X-API-Key' => 'token123' } }
    let(:show_pubs) { false }
    let(:user_without_publications) { create(:user, webaccess_id: "nopubs123") }

    before do
      create :user_organization_membership, user: user, organization: org
      create :user_organization_membership, user: user_without_publications, organization: org
      create :authorship, user: user, publication: invisible_pub
      get "/v1/users/#{webaccess_id}/publications#{params}", headers: headers
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
      context "when the user has publications" do
        context "when the user can show all publications" do
          let(:show_pubs) { true }
          it "returns all the user's visible publications" do
            expect(json_response[:data].size).to eq(10)
          end
          describe 'params:' do
            describe 'limit' do
              let(:params) { "?limit=5"}
              it "returns the specified number of publications" do
                expect(json_response[:data].size).to eq(5)
              end
            end
          end
        end
        context "when the user cannot show all publications" do
          it "returns no publications" do
            expect(json_response[:data].size).to eq(0)
          end
          describe 'params:' do
            describe 'limit' do
              let(:params) { "?limit=5"}
              it "returns no publications" do
                expect(json_response[:data].size).to eq(0)
              end
            end
          end
        end
      end
      context "when the user has no publications" do
        let(:webaccess_id) { user_without_publications.webaccess_id }
        it "returns an empty JSON data hash" do
          expect(json_response[:data].size).to eq(0)
        end
      end
      context "when an html-formatted response is requested" do
        let(:headers) { { "accept" => "text/html", 'X-API-Key' => 'token123' } }
        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end
        it "updates the usage statistics on the API token" do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end
      end
    end
    context "for an invalid webaccess_id" do
      let(:webaccess_id) { "aaa" }
      it "returns 404 not found" do
        expect(response).to have_http_status 404
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
    end
    context "for a webaccess_id of a user that is inaccessible to the given API token" do
      let(:webaccess_id) { "inaccessible" }

      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end

      it "returns 404" do
        expect(response.code).to eq '404'
      end
    end
  end

  describe 'POST /v1/users/publications' do
    let!(:user_xyz123) { create(:user_with_authorships,
                                webaccess_id: 'xyz321',
                                authorships_count: 10,
                                show_all_publications: true) }
    let!(:user_abc123) { create(:user_with_authorships,
                                webaccess_id: 'abc123',
                                authorships_count: 5,
                                show_all_publications: true) }
    let!(:user_def123) { create(:user_with_authorships,
                                webaccess_id: 'def123',
                                authorships_count: 5,
                                show_all_publications: false) }

    let!(:user_cws161) { create(:user, webaccess_id: 'cws161') }

    let!(:invisible_pub1) { create :publication, visible: false }
    let!(:invisible_pub2) { create :publication, visible: false }

    before do
      create :authorship, user: user_abc123, publication: invisible_pub1
      create :authorship, user: user_cws161, publication: invisible_pub2

      create :user_organization_membership, organization: org, user: user_xyz123
      create :user_organization_membership, organization: org, user: user_abc123
      create :user_organization_membership, organization: org, user: user_def123
      create :user_organization_membership, organization: org, user: user_cws161

      post "/v1/users/publications", params: params, headers: headers
    end
    context "given a set webaccess_id params" do
      let(:params) { { '_json': %w(abc123 xyz321 def123 cws161 fake123 inaccessible) } }
      let(:headers) { {'X-API-Key' => 'token123'} }
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
      it "returns visible publications for each valid webaccess_id" do
        expect(json_response.count).to eq(4)
        expect(json_response[:abc123][:data].count).to eq(5)
        expect(json_response[:xyz321][:data].count).to eq(10)
        expect(json_response[:def123][:data].count).to eq(0)
        expect(json_response[:cws161][:data].count).to eq(0)
        expect(json_response[:fake123]).to be_nil
        expect(json_response[:inaccessible]).to be_nil
      end
    end
  end

  describe 'GET /v1/users/:webaccess_id/etds' do
    let!(:user) { create(:user_with_committee_memberships, webaccess_id: 'xyz321', committee_memberships_count: 10) }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }
    let(:headers) { { "accept" => "application/json", 'X-API-Key' => 'token123' } }
    let(:user_without_etds) { create(:user, webaccess_id: "nocommittees123") }

    before do
      create :user_organization_membership, user: user, organization: org
      create :user_organization_membership, user: user_without_etds, organization: org
      get "/v1/users/#{webaccess_id}/etds#{params}", headers: headers
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
      context "when the user served on etd committees" do
        it "returns all the etds the user was a committee member on" do
          expect(json_response[:data].size).to eq(10)
        end
      end
      context "when the user has not served on any committees" do
        let(:webaccess_id) { user_without_etds.webaccess_id }
        it "returns an empty JSON data hash" do
          expect(json_response[:data].size).to eq(0)
        end
      end
      context "when an html-formatted response is requested" do
        let(:headers) { { "accept" => "text/html", 'X-API-Key' => 'token123' } }
        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end
        it "updates the usage statistics on the API token" do
          updated_token = token.reload
          expect(updated_token.total_requests).to eq 1
          expect(updated_token.last_used_at).not_to be_nil
        end
      end
    end
    context "for an invalid webaccess_id" do
      let(:webaccess_id) { "aaa" }
      it "returns 404 not found" do
        expect(response).to have_http_status 404
      end
      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end
    end
    context "for a webaccess_id of a user that is inaccessible to the given API token" do
      let(:webaccess_id) { "inaccessible" }

      it "updates the usage statistics on the API token" do
        updated_token = token.reload
        expect(updated_token.total_requests).to eq 1
        expect(updated_token.last_used_at).not_to be_nil
      end

      it "returns 404" do
        expect(response.code).to eq '404'
      end
    end
  end

  describe 'GET /v1/users/:webaccess_id/profile' do
    let!(:user) { create(:user,
                         first_name: "Bob",
                         last_name: "Testerson",
                         scopus_h_index: h_index,
                         webaccess_id: 'bat123',
                         pure_uuid: pure_uuid,
                         show_all_contracts: true,
                         show_all_publications: show_pubs,
                         ai_title: title,
                         ai_website: website,
                         ai_bio: bio,
                         ai_room_number: room,
                         ai_building: building,
                         orcid_identifier: 'orcid-id') }
    let(:show_pubs) { true }
    let(:headers) { { "accept" => "text/html" } }
    let(:pure_uuid) { nil }

    context "for a valid webaccess_id" do
      before do
        get "/v1/users/#{webaccess_id}/profile", headers: headers
      end

      let(:webaccess_id) { 'bat123' }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      context "when the user has no associated metadata" do
        it "returns an HTML representation of the given user's basic information" do
          expect(response.body).to eq <<~HTML
              <h2 id="md-full-name">Bob Testerson</h2>
              <div id="md-person-info">
                <ul id="md-contact-info">
                  <li><strong>Email:</strong>  <a href="mailto:bat123@psu.edu">bat123@psu.edu</a></li>
                </ul>
              </div>
            HTML
        end
      end

      context "when the user has publications that cannot be shown" do
        let(:pub1) { create :publication, title: "First Publication",
                             visible: true,
                             journal_title: "Test Journal",
                             published_on: Date.new(2010, 1, 1) }
        let(:show_pubs) { false }
        before do
          create :authorship, user: user, publication: pub1
          get "/v1/users/#{webaccess_id}/profile", headers: headers
        end

        it "returns an HTML representation of the user's profile with no publications" do
          expect(response.body).to eq <<~HTML
              <h2 id="md-full-name">Bob Testerson</h2>
              <div id="md-person-info">
                <ul id="md-contact-info">
                  <li><strong>Email:</strong>  <a href="mailto:bat123@psu.edu">bat123@psu.edu</a></li>
                </ul>
              </div>
          HTML
        end
      end

      context "when the user has associated metadata" do
        let(:other_user) { create :user, show_all_contracts: false }
        let(:h_index) { 49 }
        let(:title) { 'Professor' }
        let(:website) { 'http://example.com/mysite' }
        let(:bio) { 'Some bio content' }
        let(:pure_uuid) { 'pure-abc-123' }
        let(:room) { '123' }
        let(:building) { 'Test Building' }
        let!(:pub1) { create :publication, title: "First Publication",
                             visible: true,
                             journal_title: "Test Journal",
                             published_on: Date.new(2010, 1, 1),
                             total_scopus_citations: 4 }
        let!(:pub2) { create :publication, title: "Second Publication",
                             visible: true,
                             publisher: "Test Publisher",
                             published_on: Date.new(2015, 1, 1) }
        let!(:pub3) { create :publication, title: "Third Publication",
                             visible: true,
                             published_on: Date.new(2018, 1, 1),
                             total_scopus_citations: 5 }
        let!(:pub4) { create :publication, title: "Undated Publication",
                             visible: true }
        let!(:pub5) { create :publication,
                             title: "Invisible Publication",
                             visible: false }

        let!(:con1) { create :contract,
                             contract_type: "Contract",
                             status: "Awarded",
                             title: "Awarded Contract",
                             visible: true }
        let!(:con2) { create :contract,
                             contract_type: "Grant",
                             status: "Pending",
                             title: "Pending Grant",
                             visible: true }
        let!(:con3) { create :contract,
                             contract_type: "Grant",
                             status: "Awarded",
                             title: "Awarded Grant One",
                             sponsor: "Test Sponsor",
                             award_start_on: Date.new(2010, 1, 1),
                             award_end_on: Date.new(2010, 5, 1),
                             visible: true }
        let!(:con4) { create :contract,
                             contract_type: "Grant",
                             status: "Awarded",
                             title: "Awarded Grant Two",
                             sponsor: "Other Sponsor",
                             award_start_on: Date.new(2015, 2, 1),
                             award_end_on: Date.new(2016, 1, 1),
                             visible: true }
        let!(:con5) { create :contract,
                             contract_type: "Grant",
                             status: "Awarded",
                             title: "Awarded Grant Three",
                             sponsor: "Sponsor",
                             award_start_on: nil,
                             visible: true }
        let!(:con6) { create :contract,
                             contract_type: "Grant",
                             status: "Awarded",
                             title: "Invisible Awarded Grant",
                             visible: false }
        let!(:con7) { create :contract,
                             contract_type: "Grant",
                             status: "Awarded",
                             title: "Hidden by other",
                             visible: true }

        let!(:pres1) { create :presentation,
                              name: "Presentation Two",
                              organization: "An Organization",
                              location: "Earth",
                              visible: true}
        let!(:pres2) { create :presentation,
                              title: nil,
                              name: nil,
                              visible: true }
        let!(:pres3) { create :presentation,
                              name: "Presentation Three",
                              organization: "Org",
                              location: "Here",
                              visible: false}

        let!(:etd1) { create :etd, title: 'Master\n ETD',
                             url: "test1.edu",
                             submission_type: 'Master Thesis',
                             year: 2000,
                             author_first_name: 'Thesis',
                             author_last_name: 'Author' }
        let!(:etd2) { create :etd, title: 'PhD\n ETD',
                             url: "test2.edu",
                             submission_type: 'Dissertation',
                             year: 2010,
                             author_first_name: 'Dissertation',
                             author_last_name: 'Author' }

        let!(:nfi1) { create :news_feed_item,
                             user: user,
                             title: "Story One",
                             url: "news.edu/1",
                             published_on: Date.new(2016, 1, 2) }
        let!(:nfi2) { create :news_feed_item,
                             user: user,
                             title: "Story Two",
                             url: "news.edu/2",
                             published_on: Date.new(2018, 3, 4) }

        let!(:perf1) { create :performance,
                              title: "Performance One",
                              location: "Location One",
                              start_on: Date.new(2017, 1, 1) }
        let!(:perf2) { create :performance,
                              title: "Performance Two",
                              location: nil,
                              start_on: nil }
        let!(:perf3) { create :performance,
                              title: "Performance Three",
                              location: "Location Three",
                              start_on: nil }
        let!(:perf4) { create :performance,
                              title: "Performance Four",
                              location: nil,
                              start_on: Date.new(2018, 12, 1) }

        before do
          create :authorship, user: user, publication: pub1
          create :authorship, user: user, publication: pub2
          create :authorship, user: user, publication: pub3
          create :authorship, user: user, publication: pub4
          create :authorship, user: user, publication: pub5

          create :user_contract, user: user, contract: con1
          create :user_contract, user: user, contract: con2
          create :user_contract, user: user, contract: con3
          create :user_contract, user: user, contract: con4
          create :user_contract, user: user, contract: con5
          create :user_contract, user: user, contract: con6
          create :user_contract, user: user, contract: con7
          create :user_contract, user: other_user, contract: con7

          create :presentation_contribution, user: user, presentation: pres1
          create :presentation_contribution, user: user, presentation: pres2
          create :presentation_contribution, user: user, presentation: pres3

          create :committee_membership, user: user, etd: etd1, role: "Committee Member"
          create :committee_membership, user: user, etd: etd2, role: "Committee Member"

          create :user_performance, user: user, performance: perf1
          create :user_performance, user: user, performance: perf2
          create :user_performance, user: user, performance: perf3
          create :user_performance, user: user, performance: perf4

          get "/v1/users/#{webaccess_id}/profile", headers: headers
        end

        context "when requesting HTML" do
          it "returns an HTML representation of all of the given user's available metadata" do
            expect(response.body).to eq <<~HTML
              <h2 id="md-full-name">Bob Testerson</h2>
                <span id="md-title">Professor</span>
              <div id="md-person-info">
                <ul id="md-contact-info">
                  <li><strong>Email:</strong>  <a href="mailto:bat123@psu.edu">bat123@psu.edu</a></li>
                    <li><strong>Office:</strong>  123 Test Building</li>
                    <li><strong>Personal website:</strong>  http://example.com/mysite</li>
                </ul>
                  <ul>
                      <li><strong>Citations:</strong>  9</li>
                      <li><strong>H-Index:</strong>  49</li>
                      <li><a href="https://pennstate.pure.elsevier.com/en/persons/pure-abc-123" target="_blank">Pure Profile</a></li>
                  </ul>
              </div>
                <div id="md-bio">
                  <p>Some bio content</p>
                </div>
                <div id="md-publications">
                  <h3>Publications</h3>
                  <ul>
                      <li><span class="publication-title">Undated Publication</span></li>
                      <li><span class="publication-title">Third Publication</span>, 2018</li>
                      <li><span class="publication-title">Second Publication</span>, <span class="journal-name">Test Publisher</span>, 2015</li>
                      <li><span class="publication-title">First Publication</span>, <span class="journal-name">Test Journal</span>, 2010</li>
                  </ul>
                </div>
                <div id="md-grants">
                  <h3>Grants</h3>
                  <ul>
                      <li>Awarded Grant Three, Sponsor</li>
                      <li>Awarded Grant Two, Other Sponsor, 2/2015 - 1/2016</li>
                      <li>Awarded Grant One, Test Sponsor, 1/2010 - 5/2010</li>
                  </ul>
                </div>
                <div id="md-presentations">
                  <h3>Presentations</h3>
                  <ul>
                      <li>Presentation Two, An Organization, Earth</li>
                  </ul>
                </div>
                <div id="md-performances">
                  <h3>Performances</h3>
                  <ul>
                      <li>Performance Four, 12/1/2018</li>
                      <li>Performance One, Location One, 1/1/2017</li>
                      <li>Performance Two</li>
                      <li>Performance Three, Location Three</li>
                  </ul>
                </div>
                <div id="md-phd-advising">
                  <h3>PhD Graduate Advising</h3>
                  <ul>
                      <li>Committee Member for Dissertation Author - <a href="test2.edu" target="_blank">PhD  ETD</a> 2010</li>
                  </ul>
                </div>
                <div id="md-master-advising">
                  <h3>Master Graduate Advising</h3>
                  <ul>
                      <li>Committee Member for Thesis Author - <a href="test1.edu" target="_blank">Master  ETD</a> 2000</li>
                  </ul>
                </div>
                <div id="md-news-stories">
                  <h3>Penn State News Media Mentions</h3>
                  <ul>
                      <li><a href="news.edu/2" target="_blank">Story Two</a> 3/4/2018</li>
                      <li><a href="news.edu/1" target="_blank">Story One</a> 1/2/2016</li>
                  </ul>
                </div>
              HTML
          end
        end

        context "when requesting JSON" do
          let(:headers) { { "accept" => "application/json" } }

          it "returns a JSON representation of the given user's profile" do
            expect(json_response[:data][:attributes][:name]).to eq 'Bob Testerson'
            expect(json_response[:data][:attributes][:orcid_identifier]).to eq 'orcid-id'
          end
        end
      end
    end

    context "for an invalid webaccess_id" do
      let(:webaccess_id) { "aaa" }

      before do
        get "/v1/users/#{webaccess_id}/profile", headers: headers
      end

      it "returns 404 not found" do
        expect(response).to have_http_status 404
      end
    end
  end
end
