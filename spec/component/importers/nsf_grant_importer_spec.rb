# frozen_string_literal: true

require 'component/component_spec_helper'

describe NSFGrantImporter do
  let(:importer) { described_class.new(dirname: dirname) }

  describe '#call' do
    let!(:u1) { create(:user, first_name: 'Bethany', last_name: 'Testuser', webaccess_id: 'bat123') }
    let!(:u2) { create(:user, first_name: 'Jeff', last_name: 'Testresearcher', webaccess_id: 'jbt12') }
    let!(:u3) { create(:user, first_name: 'Richard', last_name: 'Testuser', webaccess_id: 'rat') }

    context 'when given XML files of grant data from the National Science Foundation' do
      let(:dirname) { Rails.root.join('spec', 'fixtures', 'nsf_grants') }

      context 'when no grants matching the data in the given files already exist' do
        it 'creates new grant records for each Penn State grant in the given data' do
          expect { importer.call }.to change(Grant, :count).by 2
        end

        it 'fills out new grant records with the available data' do
          importer.call
          g1 = Grant.find_by(identifier: '1934782')
          g2 = Grant.find_by(identifier: '1057936')

          expect(g1.title).to eq 'Example Grant 1'
          expect(g1.start_date).to eq Date.new(2019, 7, 1)
          expect(g1.end_date).to eq Date.new(2021, 6, 30)
          expect(g1.abstract).to eq 'Description of example grant 1'
          expect(g1.amount_in_dollars).to eq 300000
          expect(g1.agency_name).to eq 'National Science Foundation'

          expect(g2.title).to eq 'Example Grant 2'
          expect(g2.start_date).to eq Date.new(2010, 1, 1)
          expect(g2.end_date).to eq Date.new(2020, 12, 31)
          expect(g2.abstract).to eq 'Abstract for example grant 2'
          expect(g2.amount_in_dollars).to eq 5000000
          expect(g2.agency_name).to eq 'National Science Foundation'
        end

        it 'creates associations between the new grants and users based on the given data' do
          expect { importer.call }.to change(ResearcherFund, :count).by 3
          g1 = Grant.find_by(identifier: '1934782')
          g2 = Grant.find_by(identifier: '1057936')

          expect(ResearcherFund.find_by(grant: g1, user: u1)).not_to be_nil
          expect(ResearcherFund.find_by(grant: g1, user: u2)).not_to be_nil
          expect(ResearcherFund.find_by(grant: g2, user: u3)).not_to be_nil
        end
      end

      context 'when a grant matching the data in the given files already exists' do
        let!(:existing_grant) { create(:grant,
                                       agency_name: 'National Science Foundation',
                                       identifier: '1934782',
                                       title: 'Existing title',
                                       start_date: Date.new(2018, 1, 1),
                                       end_date: Date.new(2025, 1, 1),
                                       abstract: 'Existing abstract',
                                       amount_in_dollars: 20000) }

        it 'creates new grant records for each Penn State grant in the given data that does not match an existing grant' do
          expect { importer.call }.to change(Grant, :count).by 1
        end

        it 'fills out new grant records with the available data' do
          importer.call
          g = Grant.find_by(identifier: '1057936')

          expect(g.title).to eq 'Example Grant 2'
          expect(g.start_date).to eq Date.new(2010, 1, 1)
          expect(g.end_date).to eq Date.new(2020, 12, 31)
          expect(g.abstract).to eq 'Abstract for example grant 2'
          expect(g.amount_in_dollars).to eq 5000000
          expect(g.agency_name).to eq 'National Science Foundation'
        end

        it 'updates the existing grant with the given data' do
          importer.call

          expect(existing_grant.reload.title).to eq 'Example Grant 1'
          expect(existing_grant.reload.start_date).to eq Date.new(2019, 7, 1)
          expect(existing_grant.reload.end_date).to eq Date.new(2021, 6, 30)
          expect(existing_grant.reload.abstract).to eq 'Description of example grant 1'
          expect(existing_grant.reload.amount_in_dollars).to eq 300000
          expect(existing_grant.reload.agency_name).to eq 'National Science Foundation'
        end

        context 'when no associations between the existing grant and users exist' do
          it 'creates associations between the new grants and users based on the given data' do
            expect { importer.call }.to change(ResearcherFund, :count).by 3
            g1 = Grant.find_by(identifier: '1934782')
            g2 = Grant.find_by(identifier: '1057936')

            expect(ResearcherFund.find_by(grant: g1, user: u1)).not_to be_nil
            expect(ResearcherFund.find_by(grant: g1, user: u2)).not_to be_nil
            expect(ResearcherFund.find_by(grant: g2, user: u3)).not_to be_nil
          end
        end

        context 'when an association between the existing grant and a user already exists' do
          before do
            create(:researcher_fund,
                   grant: existing_grant,
                   user: u1)
          end

          it 'does not create a new association' do
            expect { importer.call }.to change(ResearcherFund, :count).by 2
          end
        end
      end
    end
  end
end
