# frozen_string_literal: true

require 'component/component_spec_helper'

describe PurePersonFinder do
  describe '#detect_publication_author' do
    let(:finder) { described_class.new }
    let(:pub) { instance_double(Publication, users: [user1, user2]) }
    let(:user1) { instance_double(User, pure_uuid: 'abc123') }
    let(:user2) { instance_double(User, pure_uuid: 'def456') }

    before do
      allow(HTTParty).to receive(:get).with(
        'https://pure.psu.edu/ws/api/524/persons/abc123',
        headers: { 'api-key' => Settings.pure.api_key }
      ).and_return response1

      allow(HTTParty).to receive(:get).with(
        'https://pure.psu.edu/ws/api/524/persons/def456',
        headers: { 'api-key' => Settings.pure.api_key }
      ).and_return response2
    end

    context 'when the given publication does not have an author that is present in the Pure dataset' do
      let(:response1) { instance_double HTTParty::Response, code: 404 }
      let(:response2) { instance_double HTTParty::Response, code: 404 }

      it 'returns nil' do
        expect(finder.detect_publication_author(pub)).to be_nil
      end
    end

    context 'when the given publication has an author that is present in the Pure dataset' do
      let(:response1) { instance_double HTTParty::Response, code: 404 }
      let(:response2) { instance_double HTTParty::Response, code: 200 }

      it 'returns the present author' do
        expect(finder.detect_publication_author(pub)).to eq user2
      end
    end
  end
end
