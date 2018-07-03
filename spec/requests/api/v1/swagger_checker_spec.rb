require 'requests/requests_spec_helper'

describe 'API::V1 Swagger Checker', type: :apivore, order: :defined do
  subject { Apivore::SwaggerChecker.instance_for('/api_docs/swagger_docs/v1/swagger.json') }

  context 'has valid paths' do
    let!(:publication_1) { create :publication }
    let(:params) { { "id" => publication_1.id } }
    let(:invalid_params) { { "id" => -2000 } }
    it { is_expected.to validate( :get, '/v1/publications/{id}', 200, params ) }
    it { is_expected.to validate( :get, '/v1/publications/{id}', 404, invalid_params ) }
    it { is_expected.to validate( :get, '/v1/publications', 200 ) }
  end

  context 'and' do
    it 'tests all documented routes' do
      expect(subject).to validate_all_paths
    end
  end
end
