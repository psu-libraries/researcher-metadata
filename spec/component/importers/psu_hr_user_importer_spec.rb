require 'component/component_spec_helper'

describe PSUHRUserImporter do
  let(:importer) { PSUHRUserImporter.new(filename: filename) }

  describe '#call' do
    let!(:dickinson) { create :organization, pure_external_identifier: 'CAMPUS-DN' }
    let!(:psu_law) { create :organization, pure_external_identifier: 'COLLEGE-PL' }
    let(:found_user1) { User.find_by(webaccess_id: 'eat123') }
    let(:found_user2) { User.find_by(webaccess_id: 'jbt456') }

    context "when given a CSV file containing user data from Penn State's HR system" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'psu_hr_users.csv') }

      context "when none of the people listed in the import data exist as users in the database" do
        it "creates a new user for each person who is a member of one of the law schools" do
          expect { importer.call }.to change { User.count }.by 2

          expect(found_user1.first_name).to eq 'Elizabeth'
          expect(found_user1.last_name).to eq 'Testington'
          expect(found_user1.penn_state_identifier).to eq '848938535'


          expect(found_user2.first_name).to eq 'John'
          expect(found_user2.last_name).to eq 'Testworth'
          expect(found_user2.penn_state_identifier).to eq '288567524'
        end

        it "creates organization membership records for the users" do
          expect { importer.call }.to change { UserOrganizationMembership.count }.by 2

          m1 = UserOrganizationMembership.find_by(user: found_user1, organization: psu_law)
          m2 = UserOrganizationMembership.find_by(user: found_user2, organization: dickinson)

          expect(m1.import_source).to eq 'HR'
          expect(m1.started_on).to eq Date.new(2016, 7, 1)

          expect(m2.import_source).to eq 'HR'
          expect(m2.started_on).to eq Date.new(2010, 11, 1)
        end
      end
    end
  end
end
