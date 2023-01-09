# frozen_string_literal: true

require 'component/component_spec_helper'

describe ETDCSVImporter do
  let(:importer) { described_class.new(filename: filename) }

  describe '#call' do
    context 'when given a well-formed .csv file of valid etd data' do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'etds.csv') }

      context 'when no etd records exist in the database' do
        it 'creates a new etd record for each row in the .csv file' do
          expect { importer.call }.to change(ETD, :count).by 3

          etd1 = ETD.find_by(webaccess_id: 'sat1')
          etd2 = ETD.find_by(webaccess_id: 'bbt2')
          etd3 = ETD.find_by(webaccess_id: 'jct3')

          expect(etd1.author_first_name).to eq 'Susan'
          expect(etd1.author_middle_name).to eq 'A'
          expect(etd1.author_last_name).to eq 'Tester'
          expect(etd1.year).to eq 2016
          expect(etd1.title).to eq 'Thesis 1'
          expect(etd1.url).to eq 'https://etda.libraries.psu.edu/catalog/11111'
          expect(etd1.submission_type).to eq 'Dissertation'
          expect(etd1.external_identifier).to eq '1'
          expect(etd1.access_level).to eq 'open_access'

          expect(etd2.author_first_name).to eq 'Bob'
          expect(etd2.author_middle_name).to eq 'B'
          expect(etd2.author_last_name).to eq 'Testuser'
          expect(etd2.year).to eq 2017
          expect(etd2.title).to eq 'Thesis 2'
          expect(etd2.url).to eq 'https://etda.libraries.psu.edu/catalog/22222'
          expect(etd2.submission_type).to eq 'Master Thesis'
          expect(etd2.external_identifier).to eq '2'
          expect(etd2.access_level).to eq 'restricted_to_institution'

          expect(etd3.author_first_name).to eq 'Jill'
          expect(etd3.author_middle_name).to eq 'C'
          expect(etd3.author_last_name).to eq 'Test'
          expect(etd3.year).to eq 2018
          expect(etd3.title).to eq 'Thesis 3'
          expect(etd3.url).to eq 'https://etda.libraries.psu.edu/catalog/33333'
          expect(etd3.submission_type).to eq 'Dissertation'
          expect(etd3.external_identifier).to eq '3'
          expect(etd3.access_level).to eq 'open_access'
        end
      end

      context 'when a ETD in the .csv file already exists in the database' do
        let!(:existing_etd) { create(:etd,
                                     webaccess_id: 'bbt2',
                                     author_first_name: 'Robert',
                                     author_middle_name: 'B',
                                     author_last_name: 'Testuser',
                                     year: 2017,
                                     title: 'Bobs Thesis',
                                     url: 'https://etda.libraries.psu.edu/catalog/22222',
                                     submission_type: 'Master Thesis',
                                     external_identifier: '2',
                                     access_level: 'restricted_to_institution',
                                     updated_by_user_at: timestamp) }

        context 'when the existing ETD has been updated by a human' do
          let(:timestamp) { Time.zone.now }

          it 'creates new records for the new ETDs and does not update the existing ETD' do
            expect { importer.call }.to change(ETD, :count).by 2

            etd1 = ETD.find_by(webaccess_id: 'sat1')
            etd2 = ETD.find_by(webaccess_id: 'bbt2')
            etd3 = ETD.find_by(webaccess_id: 'jct3')

            expect(etd1.author_first_name).to eq 'Susan'
            expect(etd1.author_middle_name).to eq 'A'
            expect(etd1.author_last_name).to eq 'Tester'
            expect(etd1.year).to eq 2016
            expect(etd1.title).to eq 'Thesis 1'
            expect(etd1.url).to eq 'https://etda.libraries.psu.edu/catalog/11111'
            expect(etd1.submission_type).to eq 'Dissertation'
            expect(etd1.external_identifier).to eq '1'
            expect(etd1.access_level).to eq 'open_access'

            expect(etd2.author_first_name).to eq 'Robert'
            expect(etd2.author_middle_name).to eq 'B'
            expect(etd2.author_last_name).to eq 'Testuser'
            expect(etd2.year).to eq 2017
            expect(etd2.title).to eq 'Bobs Thesis'
            expect(etd2.url).to eq 'https://etda.libraries.psu.edu/catalog/22222'
            expect(etd2.submission_type).to eq 'Master Thesis'
            expect(etd2.external_identifier).to eq '2'
            expect(etd2.access_level).to eq 'restricted_to_institution'

            expect(etd3.author_first_name).to eq 'Jill'
            expect(etd3.author_middle_name).to eq 'C'
            expect(etd3.author_last_name).to eq 'Test'
            expect(etd3.year).to eq 2018
            expect(etd3.title).to eq 'Thesis 3'
            expect(etd3.url).to eq 'https://etda.libraries.psu.edu/catalog/33333'
            expect(etd3.submission_type).to eq 'Dissertation'
            expect(etd3.external_identifier).to eq '3'
            expect(etd3.access_level).to eq 'open_access'
          end
        end

        context 'when the existing etd has not been updated by a human' do
          let(:timestamp) { nil }

          it 'creates new records for the new etds and updates the existing etd' do
            expect { importer.call }.to change(ETD, :count).by 2

            etd1 = ETD.find_by(webaccess_id: 'sat1')
            etd2 = ETD.find_by(webaccess_id: 'bbt2')
            etd3 = ETD.find_by(webaccess_id: 'jct3')

            expect(etd1.author_first_name).to eq 'Susan'
            expect(etd1.author_middle_name).to eq 'A'
            expect(etd1.author_last_name).to eq 'Tester'
            expect(etd1.year).to eq 2016
            expect(etd1.title).to eq 'Thesis 1'
            expect(etd1.url).to eq 'https://etda.libraries.psu.edu/catalog/11111'
            expect(etd1.submission_type).to eq 'Dissertation'
            expect(etd1.external_identifier).to eq '1'
            expect(etd1.access_level).to eq 'open_access'

            expect(etd2.author_first_name).to eq 'Bob'
            expect(etd2.author_middle_name).to eq 'B'
            expect(etd2.author_last_name).to eq 'Testuser'
            expect(etd2.year).to eq 2017
            expect(etd2.title).to eq 'Thesis 2'
            expect(etd2.url).to eq 'https://etda.libraries.psu.edu/catalog/22222'
            expect(etd2.submission_type).to eq 'Master Thesis'
            expect(etd2.external_identifier).to eq '2'
            expect(etd2.access_level).to eq 'restricted_to_institution'

            expect(etd3.author_first_name).to eq 'Jill'
            expect(etd3.author_middle_name).to eq 'C'
            expect(etd3.author_last_name).to eq 'Test'
            expect(etd3.year).to eq 2018
            expect(etd3.title).to eq 'Thesis 3'
            expect(etd3.url).to eq 'https://etda.libraries.psu.edu/catalog/33333'
            expect(etd3.submission_type).to eq 'Dissertation'
            expect(etd3.external_identifier).to eq '3'
            expect(etd3.access_level).to eq 'open_access'
          end
        end
      end
    end

    context 'when given a well-formed .csv file that contains invalid ETD data' do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'etds_invalid.csv') }

      it 'creates new records for each valid row and records an error for each invalid row' do
        importer.call
      rescue CSVImporter::ParseError
        expect(ETD.count).to eq 1

        etd = ETD.find_by(webaccess_id: 'bbt2')

        expect(etd.author_first_name).to eq 'Bob'
        expect(etd.author_middle_name).to eq 'B'
        expect(etd.author_last_name).to eq 'Testuser'
        expect(etd.year).to eq 2017
        expect(etd.title).to eq 'Thesis 2'
        expect(etd.url).to eq 'https://etda.libraries.psu.edu/catalog/22222'
        expect(etd.submission_type).to eq 'Master Thesis'
        expect(etd.external_identifier).to eq '2'
        expect(etd.access_level).to eq 'restricted_to_institution'

        expect(importer.fatal_errors.count).to eq 2
      end
    end

    context 'when given a well-formed .csv file that contains a duplicate ETD' do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'etds_duplicates.csv') }

      it 'creates a new record for each unique row and records an error' do
        importer.call
      rescue CSVImporter::ParseError
        expect(ETD.count).to eq 3

        expect(ETD.find_by(webaccess_id: 'sat1')).not_to be_nil
        expect(ETD.find_by(webaccess_id: 'bbt2')).not_to be_nil
        expect(ETD.find_by(webaccess_id: 'jct3')).not_to be_nil

        expect(importer.fatal_errors.count).to eq 1
      end
    end
  end
end
