# frozen_string_literal: true

require 'component/component_spec_helper'

describe ScholarsphereExifUploads do
  subject(:exif_uploads) { described_class.new(attributes) }

  let(:attributes) { { file_uploads_attributes: { '0' => { file: file, journal: nil } } } }
  let(:file) { double 'file', path: 'the/file/path' }

  describe '#version' do
    let(:exif_file_version) { double 'ScholarsphereExifFileVersion', version: nil }

    before {
      allow(ScholarsphereExifFileVersion).to receive(:new).and_return exif_file_version
    }

    context 'when one file upload' do
      context 'uploaded file has no exif data' do
        it 'returns nil' do
          expect(exif_uploads.version).to be_nil
          expect(exif_uploads.version_display).to be_nil
        end
      end

      context 'uploaded file is Accepted Manuscript' do
        let(:exif_file_version) { double 'ScholarsphereExifFileVersion', version: I18n.t('file_versions.accepted_version') }

        it 'returns Accepted Manuscript' do
          expect(exif_uploads.version).to eq I18n.t('file_versions.accepted_version')
          expect(exif_uploads.version_display).to eq I18n.t('file_versions.accepted_version_display')
        end
      end

      context 'uploaded file is Final Published Version' do
        let(:exif_file_version) { double 'ScholarsphereExifFileVersion', version: I18n.t('file_versions.published_version') }

        it 'returns Final Published Version' do
          expect(exif_uploads.version).to eq I18n.t('file_versions.published_version')
          expect(exif_uploads.version_display).to eq I18n.t('file_versions.published_version_display')
        end
      end
    end

    context 'when multiple file uploads' do
      let(:attributes) do
        {
          file_uploads_attributes: {
            '0' => { file: file1, journal: nil },
            '1' => { file: file2, journal: nil },
            '2' => { file: file3, journal: nil }
          }
        }
      end
      let(:file1) { double 'file', path: 'the/file1/path' }
      let(:file2) { double 'file', path: 'the/file2/path' }
      let(:file3) { double 'file', path: 'the/file3/path' }
      let(:exif_file1_version) { double 'ScholarsphereExifFileVersion', version: version1 }
      let(:exif_file2_version) { double 'ScholarsphereExifFileVersion', version: version2 }
      let(:exif_file3_version) { double 'ScholarsphereExifFileVersion', version: version3 }
      let(:options1) { { file_path: file1.path, journal: nil } }
      let(:options2) { { file_path: file2.path, journal: nil } }
      let(:options3) { { file_path: file3.path, journal: nil } }
      let(:version1) { nil }

      before {
        allow(ScholarsphereExifFileVersion).to receive(:new).with(options1).and_return exif_file1_version
        allow(ScholarsphereExifFileVersion).to receive(:new).with(options2).and_return exif_file2_version
        allow(ScholarsphereExifFileVersion).to receive(:new).with(options3).and_return exif_file3_version
      }

      context 'uploaded files does not resolve to any version' do
        let(:version2) { nil }
        let(:version3) { nil }

        it 'returns nil' do
          expect(exif_uploads.version).to be_nil
          expect(exif_uploads.version_display).to be_nil
        end
      end

      context 'uploaded files include Accepted Manuscript version' do
        let(:version2) { I18n.t('file_versions.published_version') }
        let(:version3) { I18n.t('file_versions.accepted_version') }

        it 'returns Accepted Manuscript' do
          expect(exif_uploads.version).to eq I18n.t('file_versions.accepted_version')
          expect(exif_uploads.version_display).to eq I18n.t('file_versions.accepted_version_display')
        end
      end

      context 'uploaded files include Final Published Version but not Accepted Manuscript version' do
        let(:version2) { I18n.t('file_versions.published_version') }
        let(:version3) { nil }

        it 'returns Final Published Version' do
          expect(exif_uploads.version).to eq I18n.t('file_versions.published_version')
          expect(exif_uploads.version_display).to eq I18n.t('file_versions.published_version_display')
        end
      end
    end
  end

  describe '#cache_files' do
    let(:attributes) do
      {
        file_uploads_attributes: {
          '0' => { file: file1, journal: nil },
          '1' => { file: file2, journal: nil }
        }
      }
    end
    let(:file1) { double 'file', path: 'the/file1/path', original_filename: 'file1.ext' }
    let(:file2) { double 'file', path: 'the/file2/path', original_filename: 'file2.ext' }
    let(:cache_path) { Pathname.new('tmp/uploads/cache/scholarsphere_file_uploads/1/file/cache_name') }

    before {
      allow_any_instance_of(ScholarsphereFileUploader).to receive(:cache_name).and_return('cache_name')
      allow_any_instance_of(ScholarsphereFileUploader).to receive(:object_id).and_return(1)
    }

    it 'caches uploaded files and returns cache info' do
      expect(exif_uploads.cache_files).to eq [
        { cache_path: cache_path, original_filename: 'file1.ext' },
        { cache_path: cache_path, original_filename: 'file2.ext' }
      ]
    end
  end

  describe 'validating file upload' do
    context 'when there is no file upload' do
      let(:file) { nil }

      it 'does not validate' do
        expect(exif_uploads).not_to be_valid
        expect(exif_uploads.errors[:file_uploads]).to include I18n.t('models.scholarsphere_work_deposit.validation_errors.file_upload_presence')
      end
    end

    context 'when there is at least one file upload' do
      it 'validates' do
        expect(exif_uploads).to be_valid
      end
    end
  end
end
