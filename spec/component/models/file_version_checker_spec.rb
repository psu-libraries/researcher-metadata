# frozen_string_literal: true

require 'component/component_spec_helper'

describe FileVersionChecker do
  # These tests use PDF file fixtures containing patterns/signals that indicate either
  # accepted or published versions.  The fixtures are crafted to test all the
  # permutations of logic in the FileVersionChecker class.
  subject(:pdf_file_version) { described_class.new(file_path: file_path, publication: publication) }

  let(:file_path) { "#{Rails.root}/spec/fixtures/#{test_file}" }
  let!(:publication) { create(:sample_publication,
                              title: 'test_pub_title',
                              published_on: '2000',
                              doi: 'https://doi.org/10.1234/1234',
                              publisher_name: "Jerry's Publishing Company") }
  let(:test_file) { 'pdf_check_unknown_version.pdf' }

  describe '#version' do
    context 'when unknown version' do
      it 'returns unknown' do
        expect(pdf_file_version.version).to eq 'unknown'
        expect(pdf_file_version.score).to eq 0
      end
    end

    context 'when accepted version' do
      # The test_file filename contains an acceptedVersion signal
      let(:test_file) { 'pdf_check_accepted_version_postprint.pdf' }

      it 'returns accepted version' do
        expect(pdf_file_version.version).to eq I18n.t('file_versions.accepted_version')
        expect(pdf_file_version.score).to eq -3
      end
    end

    context 'when the file contains an arXiv artifact' do
      let(:test_file) { 'watermark-6.pdf' }

      it 'returns accepted version' do
        expect(pdf_file_version.version).to eq I18n.t('file_versions.accepted_version')
      end
    end

    context 'when published version' do
      # The test_file filename contains an publishedVersion signal
      let(:test_file) { 'pdf_check_published_versionS123456abc.pdf' }

      it 'returns published version' do
        expect(pdf_file_version.version).to eq I18n.t('file_versions.published_version')
        expect(pdf_file_version.score).to eq 4
      end
    end

    context 'when checking rules file does not exist' do
      it 'raises an error with message' do
        allow(File).to receive(:exist?).and_return false
        expect {
          pdf_file_version.version
        }.to raise_error RuntimeError,
                         'Error: config/file_version_checking_rules.csv does not exist or cannot be read.'
      end
    end

    context "when there's an error during word parsing" do
      before do
        allow_any_instance_of(PDF::Reader::Page).to receive(:text).and_raise(RuntimeError)
      end

      it 'catches errors and continues parsing; returns unknown' do
        expect(pdf_file_version.version).to eq 'unknown'
        expect(pdf_file_version.score).to eq 0
      end
    end

    context "when there's an error parsing the pdf" do
      context 'when the error is a PDF::Reader error' do
        before do
          allow(PDF::Reader).to receive(:new).and_raise(PDF::Reader::MalformedPDFError)
        end

        it 'catches the error and returns unknown' do
          expect(pdf_file_version.version).to eq 'unknown'
          expect(pdf_file_version.score).to eq 0
        end
      end

      context 'when the error is not a PDF::Reader error' do
        before do
          allow(PDF::Reader).to receive(:new).and_raise(RuntimeError)
        end

        it 'raises the error' do
          expect { pdf_file_version.version }.to raise_error RuntimeError
        end
      end
    end

    context 'when the file is not a .pdf' do
      let(:test_file) { 'pdf_check_unknown_version.docx' }

      it "doesn't parse; returns unknown" do
        allow(PDF::Reader).to receive(:new)
        expect(pdf_file_version.version).to eq 'unknown'
        expect(pdf_file_version.score).to eq 0
        expect(PDF::Reader).not_to have_received(:new)
      end
    end
  end
end
