require 'component/component_spec_helper'

describe ActivityInsightUserImporter do
  let(:importer) { ActivityInsightUserImporter.new(filename: filename) }

  describe '#call' do
    context "when given a well-formed .csv file of valid user data from Activity Insight" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_users.csv') }

      context "when no user records exist in the database" do
        it "creates a new user record for each row in the .csv file" do
          expect { importer.call }.to change { User.count }.by 3

          u1 = User.find_by(webaccess_id: 'sat1')
          u2 = User.find_by(webaccess_id: 'bbt2')
          u3 = User.find_by(webaccess_id: 'jct3')

          expect(u1.first_name).to eq 'Susan'
          expect(u1.middle_name).to eq 'A'
          expect(u1.last_name).to eq 'Tester'
          expect(u1.penn_state_identifier).to eq '989465792'
          expect(u1.activity_insight_identifier).to eq '1649499'

          expect(u2.first_name).to eq 'Bob'
          expect(u2.middle_name).to eq 'B'
          expect(u2.last_name).to eq 'Testuser'
          expect(u2.penn_state_identifier).to eq '908332714'
          expect(u2.activity_insight_identifier).to eq '1949490'

          expect(u3.first_name).to eq 'Jill'
          expect(u3.middle_name).to eq 'C'
          expect(u3.last_name).to eq 'Test'
          expect(u3.penn_state_identifier).to eq '978001402'
          expect(u3.activity_insight_identifier).to eq '2081288'
        end
      end

      context "when a user in the .csv file already exists in the database" do
        let!(:existing_user) { create :user,
                                      webaccess_id: 'bbt2',
                                      first_name: 'Robert',
                                      middle_name: 'B',
                                      last_name: 'Testuser',
                                      penn_state_identifier: '987654321',
                                      activity_insight_identifier: '12345678',
                                      updated_by_user_at: timestamp }

        context "when the existing user has been updated by a human" do
          let(:timestamp) { Time.zone.now }
          it "creates new records for the new users and does not update the existing user" do
            expect { importer.call }.to change { User.count }.by 2

            u1 = User.find_by(webaccess_id: 'sat1')
            u2 = User.find_by(webaccess_id: 'bbt2')
            u3 = User.find_by(webaccess_id: 'jct3')

            expect(u1.first_name).to eq 'Susan'
            expect(u1.middle_name).to eq 'A'
            expect(u1.last_name).to eq 'Tester'
            expect(u1.penn_state_identifier).to eq '989465792'
            expect(u1.activity_insight_identifier).to eq '1649499'

            expect(u2.first_name).to eq 'Robert'
            expect(u2.middle_name).to eq 'B'
            expect(u2.last_name).to eq 'Testuser'
            expect(u2.penn_state_identifier).to eq '987654321'
            expect(u2.activity_insight_identifier).to eq '12345678'

            expect(u3.first_name).to eq 'Jill'
            expect(u3.middle_name).to eq 'C'
            expect(u3.last_name).to eq 'Test'
            expect(u3.penn_state_identifier).to eq '978001402'
            expect(u3.activity_insight_identifier).to eq '2081288'
          end
        end
        context "when the existing user has not been updated by a human" do
          let(:timestamp) { nil }
          it "creates new records for the new users and updates the existing user" do
            expect { importer.call }.to change { User.count }.by 2

            u1 = User.find_by(webaccess_id: 'sat1')
            u2 = User.find_by(webaccess_id: 'bbt2')
            u3 = User.find_by(webaccess_id: 'jct3')

            expect(u1.first_name).to eq 'Susan'
            expect(u1.middle_name).to eq 'A'
            expect(u1.last_name).to eq 'Tester'
            expect(u1.penn_state_identifier).to eq '989465792'
            expect(u1.activity_insight_identifier).to eq '1649499'

            expect(u2.first_name).to eq 'Bob'
            expect(u2.middle_name).to eq 'B'
            expect(u2.last_name).to eq 'Testuser'
            expect(u2.penn_state_identifier).to eq '908332714'
            expect(u2.activity_insight_identifier).to eq '1949490'

            expect(u3.first_name).to eq 'Jill'
            expect(u3.middle_name).to eq 'C'
            expect(u3.last_name).to eq 'Test'
            expect(u3.penn_state_identifier).to eq '978001402'
            expect(u3.activity_insight_identifier).to eq '2081288'
          end
        end
      end
    end

    context "when given a well-formed .csv file that contains invalid user data" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_users_invalid.csv') }

      it "creates new records for each valid row and records an error for each invalid row" do
        begin
          importer.call
        rescue CSVImporter::ParseError
          expect(User.count).to eq 1

          u = User.find_by(webaccess_id: 'bbt2')

          expect(u.first_name).to eq 'Bob'
          expect(u.middle_name).to eq 'B'
          expect(u.last_name).to eq 'Testuser'
          expect(u.penn_state_identifier).to eq '908332714'
          expect(u.activity_insight_identifier).to eq '1949490'

          expect(importer.fatal_errors.count).to eq 2
        end
      end
    end

    context "when given a well-formed .csv file that contains a duplicate user" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_users_duplicates.csv') }

      it "creates a new record for each unique row and records an error" do
        begin
          importer.call
        rescue CSVImporter::ParseError
          expect(User.count).to eq 3

          u1 = User.find_by(webaccess_id: 'sat1')
          u2 = User.find_by(webaccess_id: 'bbt2')
          u3 = User.find_by(webaccess_id: 'jct3')

          expect(u1.first_name).to eq 'Susan'
          expect(u1.middle_name).to eq 'A'
          expect(u1.last_name).to eq 'Tester'
          expect(u1.penn_state_identifier).to eq '989465792'
          expect(u1.activity_insight_identifier).to eq '1649499'

          expect(u2.first_name).to eq 'Bob'
          expect(u2.middle_name).to eq 'B'
          expect(u2.last_name).to eq 'Testuser'
          expect(u2.penn_state_identifier).to eq '908332714'
          expect(u2.activity_insight_identifier).to eq '1949490'

          expect(u3.first_name).to eq 'Jill'
          expect(u3.middle_name).to eq 'C'
          expect(u3.last_name).to eq 'Test'
          expect(u3.penn_state_identifier).to eq '978001402'
          expect(u3.activity_insight_identifier).to eq '2081288'

          expect(importer.fatal_errors.count).to eq 1
        end
      end
    end
  end
end