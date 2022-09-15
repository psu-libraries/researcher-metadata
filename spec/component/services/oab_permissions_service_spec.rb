# frozen_string_literal: true

require 'component/component_spec_helper'

describe OabPermissionsService, vcr: true do
  let(:service) { described_class.new(doi, version) }

  context 'when version is valid' do
    let(:version) { OabPermissionsService::VALID_VERSIONS.first }
    let(:doi) { '10.1231/abcd.54321' }

    context 'when a network error is raised' do
      before { allow(HttpService).to receive(:get).and_raise Net::ReadTimeout }

      it 'returns nils' do
        expect(service.set_statement).to be_nil
        expect(service.embargo_end_date).to be_nil
        expect(service.licence).to be_nil
      end
    end

    context 'when a JSON parsing error is raised' do
      before { allow(JSON).to receive(:parse).and_raise JSON::ParserError }

      it 'returns nils' do
        expect(service.set_statement).to be_nil
        expect(service.embargo_end_date).to be_nil
        expect(service.licence).to be_nil
      end
    end

    context 'when no error is raised' do
      describe '#set_statement' do
        it 'returns the set_statement string' do
          expect(service.set_statement).to be_nil
        end
      end

      describe '#embargo_end_date' do
        it 'returns the embargo_end_date data' do
          expect(service.embargo_end_date).to be_nil
        end
      end

      describe '#licence' do
        it 'returns the licence string' do
          expect(service.licence).to be_nil
        end
      end
    end
  end

  context 'when version is not valid' do
    let(:version) { 'invalidVersion' }
    let(:doi) { '10.1231/abcd.54321' }

    it 'raises and error' do
      expect{ service }.to raise_error OabPermissionsService::InvalidVersion
    end
  end
end
