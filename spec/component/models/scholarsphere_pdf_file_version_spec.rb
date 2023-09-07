# frozen_string_literal: true

require 'component/component_spec_helper'

describe ScholarspherePdfFileVersion do
  subject(:pdf_file_version) { described_class.new(file_path: file_path, publication: publication) }

  let(:file_path) { "#{Rails.root}/spec/fixtures/#{test_file}" }
  let!(:publication) { create(:sample_publication, title: 'test_pub_title Revision',
                                                   published_on: '2000',
                                                   doi: 'https://doi.org/10.1234/1234',
                                                   publisher_name: "Jerry's Publishing Company") }
  let(:test_file) { 'pdf_check_unknown_version.pdf' }

  describe '#version' do
    context 'when unknown version' do
      before do
        publication.update title: 'test_pub_title'
      end

      it 'returns unknown' do
        expect(pdf_file_version.version).to eq 'unknown'
        expect(pdf_file_version.score).to eq 0
      end
    end

    context 'when accepted version' do
      let(:test_file) { 'pdf_check_accepted_version_postprint.pdf' }

      it 'returns accepted version' do
        expect(pdf_file_version.version).to eq I18n.t('file_versions.accepted_version')
        expect(pdf_file_version.score).to eq -4
      end
    end

    context 'when published version' do
      let(:test_file) { 'pdf_check_published_versionS123456abc.pdf' }

      it 'returns published version' do
        expect(pdf_file_version.version).to eq I18n.t('file_versions.published_version')
        expect(pdf_file_version.score).to eq 3
      end
    end
  end
end
