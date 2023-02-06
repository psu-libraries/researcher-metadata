# frozen_string_literal: true

require 'component/component_spec_helper'

describe ScholarspherePdfFileVersion do
  subject(:pdf_file_version) { described_class.new(file_meta: file_meta, publication_meta: publication_meta) }

  let(:file_meta) { { original_filename: 'test_file', cache_path: "#{Rails.root}/spec/fixtures/#{test_file}" }.to_json }
  let(:publication_meta) { { title: 'test_pub_title', year: '2000', doi: 'test_doi', publisher: 'Test Publisher' } }
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
