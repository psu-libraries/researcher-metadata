# frozen_string_literal: true

require 'component/component_spec_helper'

describe CommitteeImporter do
  let(:importer) { described_class.new(filename: filename) }
  let!(:user_abc1) { create(:user, webaccess_id: 'abc1') }
  let!(:user_abc2) { create(:user, webaccess_id: 'abc2') }

  describe '#call' do
    context 'when given a well-formed .csv file of valid etd committee data' do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'etd_committees.csv') }

      context 'when no etd records exist in the database' do
        it 'does not create any committee memberships' do
          expect { importer.call }.not_to change(CommitteeMembership, :count)
        end
      end

      context 'when etd records exist in the database' do
        let!(:etd_1) {
          create(:etd,
                 webaccess_id: 'bbt2',
                 author_first_name: 'Robert',
                 author_middle_name: 'B',
                 author_last_name: 'Testuser',
                 year: 2017,
                 title: 'Bobs Thesis',
                 url: 'https://etda.libraries.psu.edu/catalog/22222bbt2',
                 submission_type: 'Dissertation',
                 external_identifier: '22222',
                 access_level: 'open_access',
                 updated_by_user_at: nil)
        }

        context 'when no etd committee membership records exist in the database' do
          it 'creates a new committee membership record for each row in the .csv file' do
            expect { importer.call }.to change(CommitteeMembership, :count).by 3

            expect(CommitteeMembership.find_by(
                     etd: etd_1, user: user_abc1, role: 'Dissertation Advisor'
                   )).not_to be_nil
            expect(CommitteeMembership.find_by(
                     etd: etd_1, user: user_abc1, role: 'Committee Chair'
                   )).not_to be_nil
            expect(CommitteeMembership.find_by(
                     etd: etd_1, user: user_abc2, role: 'Committee Member'
                   )).not_to be_nil
          end
        end

        context 'when a committee membership in the .csv file already exists in the database' do
          let!(:cm) { create(:committee_membership, etd: etd_1, user: user_abc1, role: 'Dissertation Advisor') }

          it 'creates new records for the new committee memberships and does not update the existing membership' do
            expect { importer.call }.to change(CommitteeMembership, :count).by 2

            expect(CommitteeMembership.find_by(
                     etd: etd_1, user: user_abc1, role: 'Dissertation Advisor'
                   )).not_to be_nil
            expect(CommitteeMembership.find_by(
                     etd: etd_1, user: user_abc1, role: 'Committee Chair'
                   )).not_to be_nil
            expect(CommitteeMembership.find_by(
                     etd: etd_1, user: user_abc2, role: 'Committee Member'
                   )).not_to be_nil
          end
        end
      end
    end

    context 'when given a well-formed .csv file that contains a duplicate committee membership' do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'etd_committees_duplicates.csv') }

      it 'creates a new record for each unique row and records an error' do
        importer.call
      rescue CSVImporter::ParseError
        expect(CommitteeMembership.count).to eq 3
        expect(importer.fatal_errors.count).to eq 1
      end
    end

    context 'when given a well-formed .csv file that contains invalid committee membership data' do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'etd_committees_invalid.csv') }

      it 'creates new records for each valid row and records an error for each invalid row' do
        importer.call
      rescue CSVImporter::ParseError
        expect(CommitteeMembership.count).to eq 1
      end
    end
  end
end
