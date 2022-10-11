require 'spec_helper'

describe 'Apivore::RailsShim' do

  describe '.action_dispatch_request_args' do
    subject {
      Apivore::RailsShim.action_dispatch_request_args(
        path,
        params: params,
        headers: headers
      )
    }
    let(:path) { '/posts' }
    let(:params) { { 'foo' => 'bar' } }
    let(:headers) { { 'X-Foo' => 'baz' } }

    it 'returns path as a positional argument and params and headers as keyword arguments' do
      expect(subject).to eq({ path: path, params: params, headers: headers })
    end
  end
end
