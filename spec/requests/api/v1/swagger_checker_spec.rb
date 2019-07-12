require 'requests/requests_spec_helper'

describe 'API::V1 Swagger Checker', type: :apivore, order: :defined do
  subject { Apivore::SwaggerChecker.instance_for('/api_docs/swagger_docs/v1/swagger.json') }

  context 'has valid paths' do
    let!(:publication_1) { create :publication, visible: true }
    let!(:user) { create(:user_with_authorships, webaccess_id: 'xyz321', authorships_count: 10) }
    let!(:user_with_contracts) { create(:user_with_contracts, webaccess_id: 'con123', contracts_count: 10) }
    let!(:user_with_presentations) { create(:user_with_presentations, webaccess_id: 'pres123', presentations_count: 10) }
    let!(:user_with_committee_memberships) { create(:user_with_committee_memberships, webaccess_id: 'etd123', committee_memberships_count: 10) }
    let!(:user_with_news_feed_items) { create(:user_with_news_feed_items, webaccess_id: 'nfi123', news_feed_items_count: 10) }
    let!(:user_with_performances) { create(:user_with_performances, webaccess_id: 'per123', performances_count: 10) }
    let!(:user_with_organization_memberships) { create(:user_with_organization_memberships, webaccess_id: 'org123') }
    let!(:api_token) { create :api_token, token: 'token123' }
    let(:publications_params) { {'query_string': 'limit=1', '_headers' => {'X-API-Key' => 'token123'}} }
    let(:organizations_params) { {'_headers' => {'X-API-Key' => 'token123'}} }
    let(:publication_params) { {"id" => publication_1.id, 'query_string': 'limit=1', '_headers' => {'X-API-Key' => 'token123'}} }
    let(:user_publications_params) {
      {
        "webaccess_id" => user.webaccess_id,
        "_headers" => {'accept' => 'application/json', 'X-API-Key' => 'token123'},
        "_query_string": "start_year=2018&end_year=2018&order_first_by=citation_count_desc&order_second_by=title_asc&limit=10"
      }
    }
    let(:user_contracts_params) {
      {
        "webaccess_id" => user_with_contracts.webaccess_id,
        "_headers" => {'accept' => 'application/json', 'X-API-Key' => 'token123'}
      }
    }
    let(:invalid_user_contracts_params) {
      {
        "webaccess_id" => "aaa",
        "_headers" => {'accept' => 'application/json', 'X-API-Key' => 'token123'},
      }
    }
    let(:user_presentations_params) {
      {
        "webaccess_id" => user_with_presentations.webaccess_id,
        "_headers" => {'accept' => 'application/json', 'X-API-Key' => 'token123'}
      }
    }
    let(:invalid_user_presentations_params) {
      {
        "webaccess_id" => "aaa",
        "_headers" => {'accept' => 'application/json', 'X-API-Key' => 'token123'},
      }
    }
    let(:user_with_committee_memberships_params) {
      {
        "webaccess_id" => user_with_committee_memberships.webaccess_id,
        "_headers" => {'accept' => 'application/json', 'X-API-Key' => 'token123'}
      }
    }
    let(:invalid_user_with_committee_memberships_params) {
      {
        "webaccess_id" => "aaa",
        "_headers" => {'accept' => 'application/json', 'X-API-Key' => 'token123'},
      }
    }
    let(:user_news_feed_items_params) {
      {
        "webaccess_id" => user_with_news_feed_items.webaccess_id,
        "_headers" => {'accept' => 'application/json', 'X-API-Key' => 'token123'}
      }
    }
    let(:invalid_user_news_feed_items_params) {
      {
        "webaccess_id" => "aaa",
        "_headers" => {'accept' => 'application/json', 'X-API-Key' => 'token123'},
      }
    }
    let(:user_performances_params) {
      {
        "webaccess_id" => user_with_performances.webaccess_id,
        "_headers" => {'accept' => 'application/json', 'X-API-Key' => 'token123'}
      }
    }
    let(:invalid_user_performances_params) {
      {
        "webaccess_id" => "aaa",
        "_headers" => {'accept' => 'application/json', 'X-API-Key' => 'token123'},
      }
    }
    let(:user_organization_memberships_params) {
      {
        "webaccess_id" => user_with_organization_memberships.webaccess_id,
        "_headers" => {'accept' => 'application/json', 'X-API-Key' => 'token123'}
      }
    }
    let(:invalid_user_organization_memberships_params) {
      {
        "webaccess_id" => "aaa",
        "_headers" => {'accept' => 'application/json', 'X-API-Key' => 'token123'},
      }
    }
    let(:invalid_user_profile_params) {
      {
        "webaccess_id" => "aaa",
        "_headers" => {'accept' => 'text/html'},
      }
    }
    let(:invalid_publication_params) { {"id" => -2000, '_headers' => {'X-API-Key' => 'token123'}} }
    let(:invalid_user_publications_params) {
      {
        "webaccess_id" => "aaa",
        "_headers" => {'accept' => 'application/json', 'X-API-Key' => 'token123'},
      }
    }
    let(:users_publications_params) {
      {
        '_json': %w(abc123 xyz321 cws161 fake123),
        '_query_string': 'start_year=2018&end_year=2018&order_first_by=citation_count_desc&order_second_by=title_asc',
        '_headers' => {'X-API-Key' => 'token123'}
      }
    }
    let(:unauthorized_params) {
      {
        "id" => publication_1.id,
        "webaccess_id" => user.webaccess_id,
        '_headers' => {'X-API-Key' => 'bad_token'}
      }
    }

    it { is_expected.to validate( :get, '/v1/publications', 200, publications_params ) }
    it { is_expected.to validate( :get, '/v1/publications', 401, unauthorized_params ) }

    it { is_expected.to validate( :get, '/v1/organizations', 200, organizations_params ) }
    it { is_expected.to validate( :get, '/v1/organizations', 401, unauthorized_params ) }

    it { is_expected.to validate( :get, '/v1/publications/{id}', 200, publication_params ) }
    it { is_expected.to validate( :get, '/v1/publications/{id}', 401, unauthorized_params ) }
    it { is_expected.to validate( :get, '/v1/publications/{id}', 404, invalid_publication_params ) }

    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/publications', 200, user_publications_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/publications', 401, unauthorized_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/publications', 404, invalid_user_publications_params ) }

    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/contracts', 200, user_contracts_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/contracts', 401, unauthorized_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/contracts', 404, invalid_user_contracts_params ) }

    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/performances', 200, user_performances_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/performances', 401, unauthorized_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/performances', 404, invalid_user_performances_params ) }

    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/presentations', 200, user_presentations_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/presentations', 401, unauthorized_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/presentations', 404, invalid_user_presentations_params ) }

    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/etds', 200, user_with_committee_memberships_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/etds', 401, unauthorized_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/etds', 404, invalid_user_with_committee_memberships_params ) }

    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/news_feed_items', 200, user_news_feed_items_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/news_feed_items', 401, unauthorized_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/news_feed_items', 404, invalid_user_news_feed_items_params ) }

    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/organization_memberships', 200, user_organization_memberships_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/organization_memberships', 401, unauthorized_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/organization_memberships', 404, invalid_user_organization_memberships_params ) }

    it { is_expected.to validate( :post, '/v1/users/publications', 200, users_publications_params ) }
    it { is_expected.to validate( :post, '/v1/users/publications', 401, unauthorized_params ) }

    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/profile', 404, invalid_user_profile_params ) }
  end

  context 'and' do
    before do
      # Apivore can't handle a non-JSON (HTML) response, so ignore it
      subject.untested_mappings.delete '/v1/users/{webaccess_id}/profile'
    end

    it 'tests all documented routes' do
      expect(subject).to validate_all_paths
    end
  end
end
