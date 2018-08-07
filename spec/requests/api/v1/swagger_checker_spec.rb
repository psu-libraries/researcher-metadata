require 'requests/requests_spec_helper'

describe 'API::V1 Swagger Checker', type: :apivore, order: :defined do
  subject { Apivore::SwaggerChecker.instance_for('/api_docs/swagger_docs/v1/swagger.json') }

  context 'has valid paths' do
    let!(:publication_1) { create :publication }
    let!(:user) { create(:user_with_authorships, webaccess_id: 'xyz321', authorships_count: 10) }
    let(:publications_params) { { "id" => publication_1.id } }
    let(:user_publications_params) { { "webaccess_id" => user.webaccess_id } }
    let(:users_publications_params) { { '_json': %w(abc123 xyz321 cws161 fake123) } }
    let(:invalid_publications_params) { { "id" => -2000 } }
    let(:invalid_user_publications_params) { { "webaccess_id" => "aaa" } }
    it { is_expected.to validate( :get, '/v1/publications/{id}', 200, publications_params ) }
    it { is_expected.to validate( :get, '/v1/publications/{id}', 404, invalid_publications_params ) }
    it { is_expected.to validate( :get, '/v1/publications', 200, {"_query_string" => "limit=1"} ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/publications', 404, invalid_user_publications_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/publications', 200, user_publications_params ) }
    it { is_expected.to validate( :get, '/v1/users/{webaccess_id}/publications', 200, {"webaccess_id" => "xyz321", "_query_string" => "limit=1"} ) }
    it { is_expected.to validate( :post, '/v1/users/publications', 200, users_publications_params ) }
  end

  context 'and' do
    it 'tests all documented routes' do
      expect(subject).to validate_all_paths
    end
  end
end
