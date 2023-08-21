# frozen_string_literal: true

require 'component/component_spec_helper'

describe ScholarspherePdfFileVersion do
  subject(:pdf_file_version) { described_class.new(file_path: file_path, publication: publication) }

  let(:file_path) { "#{Rails.root}/spec/fixtures/#{test_file}" }
  let!(:publication) { create(:publication, title: 'test_pub_title', 
                                            published_on: '2000', 
                                            doi: 'https://doi.org/10.1234/1234') }
  let(:test_file) { 'pdf_check_unknown_version.pdf' }

  describe '#version' do
    context 'when unknown version' do
      it 'returns unknown' do
        expect(pdf_file_version.version).to eq 'unknown'
      end
    end

    context 'when accepted version' do
      let(:test_file) { 'pdf_check_accepted_version.pdf' }

      it 'returns accepted version' do
        expect(pdf_file_version.version).to eq I18n.t('file_versions.accepted_version')
      end
    end

    context 'when published version' do
      let(:test_file) { 'pdf_check_published_version.pdf' }

      it 'returns published version' do
        expect(pdf_file_version.version).to eq I18n.t('file_versions.published_version')
      end
    end
  end
end
