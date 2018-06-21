require 'component/component_spec_helper'

class SpecifiedImporter < CSVImporter
  # model_class is more a convenience method for testing purposes. Specified
  # Importers don't require this method be defined.
  def model_class
    Publication
  end

  def row_to_object(row)
    Publication.new(row)
  end

  def bulk_import(objects)
    Publication.import(objects)
  end
end

describe CSVImporter do
  subject(:importer){ SpecifiedImporter.new filename: filename }
  let(:filename) { fixture('dummy-publications-10.csv') }

  it { is_expected.to have_attr_accessor :filename }
  it { is_expected.to have_attr_accessor :fatal_errors }
  it { is_expected.to have_attr_accessor :batch_size }

  describe '#initialize' do
    it 'accepts a filename parameter' do
      importer = CSVImporter.new(filename: filename)
      expect(importer.filename).to eq filename
    end
    it 'ensures the given file exists' do
      expect{ CSVImporter.new(filename: 'does/not/exist') }.to raise_error Errno::ENOENT
    end

    context 'for an empty file' do
      let(:empty_file){ fixture('error_unreadable') }
      before{ FileUtils.touch empty_file }
      after { FileUtils.rm empty_file }
      let(:csv_importer) { CSVImporter.new( filename: empty_file ) }
      let(:called_importer) { csv_importer.call }
      it 'raises a an error' do
        expect{ called_importer }.to raise_error EOFError
      end
      it 'sets fatal errors' do
        begin
          csv_importer.call
        rescue
          expect(csv_importer.fatal_errors[0]).to match('File is empty')
          expect(csv_importer.fatal_errors[1]).to match('File has no records')
        end
      end
    end

    context 'for a file with one line' do
      let(:file_with_no_records){ fixture('file_with_no_records.csv') }
      let(:csv_importer) { CSVImporter.new( filename: file_with_no_records ) }
      let(:called_importer) { csv_importer.call }
      it 'raises a an error' do
        expect{ called_importer }.to raise_error CSVImporter::ParseError
      end
      it 'sets a fatal error' do
        begin
          csv_importer.call
        rescue
          expect(csv_importer.fatal_errors[0]).to match('File has no records')
        end
      end
    end
  end

  it 'forces subclasses to define #row_to_object' do
    expect{
      CSVImporter.new(filename: filename).send(:row_to_object, [])
    }.to raise_error(NotImplementedError)
  end

  it 'forces subclasses to define #bulk_import' do
    expect{
      CSVImporter.new(filename: filename).send(:bulk_import, [])
    }.to raise_error(NotImplementedError)
  end

  describe '#call' do
    context 'under normal circumstances' do
      it 'calls #row_to_object with each row' do
        expect(importer).to receive(:row_to_object).exactly(10).times
        # the line above will not return a valid model for the importer to save,
        # and that's ok. We'll just rescue it.
        importer.call rescue ParseError
      end

      it 'saves the results to the database' do
        expect{ importer.call }.to change{ importer.model_class.count }.by(10)
      end
    end

    context 'upon encountering an error' do
      before do
        allow( importer ).to receive(:row_to_object).and_raise( 'Something horrible happened' )
      end

      it 'raises a CSVImporter::ParseError' do
        expect{ importer.call }.to raise_error( CSVImporter::ParseError )
      end

      it 'provides a list of all errors encountered in the file' do
        importer.call rescue nil

        expect( importer.fatal_errors_encountered? ).to be true
        expect( importer.fatal_errors.length ).to eq 10

        expect( importer.fatal_errors[0] ).to match( /Line 1/ )
        expect( importer.fatal_errors[0] ).to match( /Something horrible happened/ )

        expect( importer.fatal_errors[1] ).to match( /Line 2/ )
      end
    end
  end
end
