require 'component/component_spec_helper'

describe PureUserImporter do
  let(:importer) { PureUserImporter.new(filename: filename) }

  describe '#call' do
    context "when given a well-formed .json file of valid user data from Pure" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'pure_users.json') }

      context "when no user records exist in the database" do
        it "creates a new user record for each user object in the .json file" do
          expect { importer.call }.to change { User.count }.by 3

          u1 = User.find_by(webaccess_id: 'sat1')
          u2 = User.find_by(webaccess_id: 'bbt2')
          u3 = User.find_by(webaccess_id: 'jct3')

          expect(u1.first_name).to eq 'Susan'
          expect(u1.middle_name).to eq 'A'
          expect(u1.last_name).to eq 'Tester'
          expect(u1.pure_uuid).to eq '9530a014-c29f-4081-88ae-b923dc919001'

          expect(u2.first_name).to eq 'Bob'
          expect(u2.middle_name).to eq 'B'
          expect(u2.last_name).to eq 'Testuser'
          expect(u2.pure_uuid).to eq 'a9ea5e62-9b39-4281-a759-e1c58f0ec582'

          expect(u3.first_name).to eq 'Jill'
          expect(u3.middle_name).to be_nil
          expect(u3.last_name).to eq 'Test'
          expect(u3.pure_uuid).to eq '0177f1b1-bf3c-4f8d-af2a-10fe0034754c'
        end
      end

      context "when a user in the .json file already exists in the database" do
        let!(:existing_user) { create :user,
                                      webaccess_id: 'bbt2',
                                      first_name: 'Robert',
                                      middle_name: 'B',
                                      last_name: 'Testuser',
                                      penn_state_identifier: '987654321',
                                      pure_uuid: '12345678',
                                      updated_by_user_at: timestamp,
                                      activity_insight_identifier: ai_id }
        let(:ai_id) { nil }
        let(:timestamp) { nil }

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
            expect(u1.pure_uuid).to eq '9530a014-c29f-4081-88ae-b923dc919001'

            expect(u2.first_name).to eq 'Robert'
            expect(u2.middle_name).to eq 'B'
            expect(u2.last_name).to eq 'Testuser'
            expect(u2.pure_uuid).to eq '12345678'

            expect(u3.first_name).to eq 'Jill'
            expect(u3.middle_name).to be_nil
            expect(u3.last_name).to eq 'Test'
            expect(u3.pure_uuid).to eq '0177f1b1-bf3c-4f8d-af2a-10fe0034754c'
          end
        end

        context "when the existing user has been imported from Activity Insight" do
          let(:ai_id) { '12345678' }
          it "creates new records for the new users and does not update the existing user" do
            expect { importer.call }.to change { User.count }.by 2

            u1 = User.find_by(webaccess_id: 'sat1')
            u2 = User.find_by(webaccess_id: 'bbt2')
            u3 = User.find_by(webaccess_id: 'jct3')

            expect(u1.first_name).to eq 'Susan'
            expect(u1.middle_name).to eq 'A'
            expect(u1.last_name).to eq 'Tester'
            expect(u1.pure_uuid).to eq '9530a014-c29f-4081-88ae-b923dc919001'

            expect(u2.first_name).to eq 'Robert'
            expect(u2.middle_name).to eq 'B'
            expect(u2.last_name).to eq 'Testuser'
            expect(u2.pure_uuid).to eq '12345678'

            expect(u3.first_name).to eq 'Jill'
            expect(u3.middle_name).to be_nil
            expect(u3.last_name).to eq 'Test'
            expect(u3.pure_uuid).to eq '0177f1b1-bf3c-4f8d-af2a-10fe0034754c'
          end
        end

        context "when the existing user has not been updated by a human or imported from Activity Insight" do
          it "creates new records for the new users and updates the existing user" do
            expect { importer.call }.to change { User.count }.by 2

            u1 = User.find_by(webaccess_id: 'sat1')
            u2 = User.find_by(webaccess_id: 'bbt2')
            u3 = User.find_by(webaccess_id: 'jct3')

            expect(u1.first_name).to eq 'Susan'
            expect(u1.middle_name).to eq 'A'
            expect(u1.last_name).to eq 'Tester'
            expect(u1.pure_uuid).to eq '9530a014-c29f-4081-88ae-b923dc919001'

            expect(u2.first_name).to eq 'Bob'
            expect(u2.middle_name).to eq 'B'
            expect(u2.last_name).to eq 'Testuser'
            expect(u2.pure_uuid).to eq 'a9ea5e62-9b39-4281-a759-e1c58f0ec582'

            expect(u3.first_name).to eq 'Jill'
            expect(u3.middle_name).to be_nil
            expect(u3.last_name).to eq 'Test'
            expect(u3.pure_uuid).to eq '0177f1b1-bf3c-4f8d-af2a-10fe0034754c'
          end
        end
      end
    end
  end
end