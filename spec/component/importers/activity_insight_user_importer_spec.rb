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
          expect(u1.ai_title).to eq 'Associate Professor of Business'
          expect(u1.ai_rank).to eq 'Associate Professor'
          expect(u1.ai_endowed_title).to be_nil
          expect(u1.orcid_identifier).to eq 'orcid-1'
          expect(u1.ai_alt_name).to be_nil
          expect(u1.ai_building).to eq 'HAMMERMILL/ZURN BLDG'
          expect(u1.ai_room_number).to eq '33'
          expect(u1.ai_office_area_code).to eq 814
          expect(u1.ai_office_phone_1).to eq 123
          expect(u1.ai_office_phone_2).to eq 4567
          expect(u1.ai_fax_area_code).to be_nil
          expect(u1.ai_fax_1).to be_nil
          expect(u1.ai_fax_2).to be_nil
          expect(u1.ai_google_scholar).to eq 'gs1'
          expect(u1.ai_website).to eq 'http://example.com/mysite'
          expect(u1.ai_bio).to eq 'bio1'

          expect(u2.first_name).to eq 'Bob'
          expect(u2.middle_name).to eq 'B'
          expect(u2.last_name).to eq 'Testuser'
          expect(u2.penn_state_identifier).to eq '908332714'
          expect(u2.activity_insight_identifier).to eq '1949490'
          expect(u2.ai_title).to be_nil
          expect(u2.ai_rank).to eq 'Professor'
          expect(u2.ai_endowed_title).to eq 'Distinguished Professor'
          expect(u2.orcid_identifier).to be_nil
          expect(u2.ai_alt_name).to be_nil
          expect(u2.ai_building).to eq 'FREAR SO BL'
          expect(u2.ai_room_number).to eq '431S'
          expect(u2.ai_office_area_code).to eq 814
          expect(u2.ai_office_phone_1).to eq 789
          expect(u2.ai_office_phone_2).to eq 152
          expect(u2.ai_fax_area_code).to be_nil
          expect(u2.ai_fax_1).to be_nil
          expect(u2.ai_fax_2).to be_nil
          expect(u2.ai_google_scholar).to eq 'gs2'
          expect(u2.ai_website).to eq 'myresearch.net'
          expect(u2.ai_bio).to eq 'bio2'

          expect(u3.first_name).to eq 'Jill'
          expect(u3.middle_name).to eq 'C'
          expect(u3.last_name).to eq 'Test'
          expect(u3.penn_state_identifier).to eq '978001402'
          expect(u3.activity_insight_identifier).to eq '2081288'
          expect(u3.ai_title).to be_nil
          expect(u3.ai_rank).to eq 'Research Associate'
          expect(u3.ai_endowed_title).to eq 'Special Title'
          expect(u3.orcid_identifier).to be_nil
          expect(u3.ai_alt_name).to eq 'J. C. Test'
          expect(u3.ai_building).to be_nil
          expect(u3.ai_room_number).to be_nil
          expect(u3.ai_office_area_code).to be_nil
          expect(u3.ai_office_phone_1).to be_nil
          expect(u3.ai_office_phone_2).to be_nil
          expect(u3.ai_fax_area_code).to eq 814
          expect(u3.ai_fax_1).to eq 555
          expect(u3.ai_fax_2).to eq 5555
          expect(u3.ai_google_scholar).to eq 'gs3'
          expect(u3.ai_website).to be_nil
          expect(u3.ai_bio).to eq 'bio3'
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
                                      ai_title: 'existing title',
                                      ai_rank: 'existing rank',
                                      ai_endowed_title: 'existing endowed',
                                      orcid_identifier: 'existing orcid',
                                      ai_alt_name: 'existing alt name',
                                      ai_building: 'existing building',
                                      ai_room_number: 'existing room',
                                      ai_office_area_code: 111,
                                      ai_office_phone_1: 222,
                                      ai_office_phone_2: 3333,
                                      ai_fax_area_code: 123,
                                      ai_fax_1: 456,
                                      ai_fax_2: 7890,
                                      ai_google_scholar: 'existing google scholar',
                                      ai_website: 'http://existing-website.net',
                                      ai_bio: 'existing bio',
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
            expect(u1.ai_title).to eq 'Associate Professor of Business'
            expect(u1.ai_rank).to eq 'Associate Professor'
            expect(u1.ai_endowed_title).to be_nil
            expect(u1.orcid_identifier).to eq 'orcid-1'
            expect(u1.ai_alt_name).to be_nil
            expect(u1.ai_building).to eq 'HAMMERMILL/ZURN BLDG'
            expect(u1.ai_room_number).to eq '33'
            expect(u1.ai_office_area_code).to eq 814
            expect(u1.ai_office_phone_1).to eq 123
            expect(u1.ai_office_phone_2).to eq 4567
            expect(u1.ai_fax_area_code).to be_nil
            expect(u1.ai_fax_1).to be_nil
            expect(u1.ai_fax_2).to be_nil
            expect(u1.ai_google_scholar).to eq 'gs1'
            expect(u1.ai_website).to eq 'http://example.com/mysite'
            expect(u1.ai_bio).to eq 'bio1'

            expect(u2.first_name).to eq 'Robert'
            expect(u2.middle_name).to eq 'B'
            expect(u2.last_name).to eq 'Testuser'
            expect(u2.penn_state_identifier).to eq '987654321'
            expect(u2.activity_insight_identifier).to eq '12345678'
            expect(u2.ai_title).to eq 'existing title'
            expect(u2.ai_rank).to eq 'existing rank'
            expect(u2.ai_endowed_title).to eq 'existing endowed'
            expect(u2.orcid_identifier).to eq 'existing orcid'
            expect(u2.ai_alt_name).to eq 'existing alt name'
            expect(u2.ai_building).to eq 'existing building'
            expect(u2.ai_room_number).to eq 'existing room'
            expect(u2.ai_office_area_code).to eq 111
            expect(u2.ai_office_phone_1).to eq 222
            expect(u2.ai_office_phone_2).to eq 3333
            expect(u2.ai_fax_area_code).to eq 123
            expect(u2.ai_fax_1).to eq 456
            expect(u2.ai_fax_2).to eq 7890
            expect(u2.ai_google_scholar).to eq 'existing google scholar'
            expect(u2.ai_website).to eq 'http://existing-website.net'
            expect(u2.ai_bio).to eq 'existing bio'

            expect(u3.first_name).to eq 'Jill'
            expect(u3.middle_name).to eq 'C'
            expect(u3.last_name).to eq 'Test'
            expect(u3.penn_state_identifier).to eq '978001402'
            expect(u3.activity_insight_identifier).to eq '2081288'
            expect(u3.ai_title).to be_nil
            expect(u3.ai_rank).to eq 'Research Associate'
            expect(u3.ai_endowed_title).to eq 'Special Title'
            expect(u3.orcid_identifier).to be_nil
            expect(u3.ai_alt_name).to eq 'J. C. Test'
            expect(u3.ai_building).to be_nil
            expect(u3.ai_room_number).to be_nil
            expect(u3.ai_office_area_code).to be_nil
            expect(u3.ai_office_phone_1).to be_nil
            expect(u3.ai_office_phone_2).to be_nil
            expect(u3.ai_fax_area_code).to eq 814
            expect(u3.ai_fax_1).to eq 555
            expect(u3.ai_fax_2).to eq 5555
            expect(u3.ai_google_scholar).to eq 'gs3'
            expect(u3.ai_website).to be_nil
            expect(u3.ai_bio).to eq 'bio3'
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
            expect(u1.ai_title).to eq 'Associate Professor of Business'
            expect(u1.ai_rank).to eq 'Associate Professor'
            expect(u1.ai_endowed_title).to be_nil
            expect(u1.orcid_identifier).to eq 'orcid-1'
            expect(u1.ai_alt_name).to be_nil
            expect(u1.ai_building).to eq 'HAMMERMILL/ZURN BLDG'
            expect(u1.ai_room_number).to eq '33'
            expect(u1.ai_office_area_code).to eq 814
            expect(u1.ai_office_phone_1).to eq 123
            expect(u1.ai_office_phone_2).to eq 4567
            expect(u1.ai_fax_area_code).to be_nil
            expect(u1.ai_fax_1).to be_nil
            expect(u1.ai_fax_2).to be_nil
            expect(u1.ai_google_scholar).to eq 'gs1'
            expect(u1.ai_website).to eq 'http://example.com/mysite'
            expect(u1.ai_bio).to eq 'bio1'

            expect(u2.first_name).to eq 'Bob'
            expect(u2.middle_name).to eq 'B'
            expect(u2.last_name).to eq 'Testuser'
            expect(u2.penn_state_identifier).to eq '908332714'
            expect(u2.activity_insight_identifier).to eq '1949490'
            expect(u2.ai_title).to be_nil
            expect(u2.ai_rank).to eq 'Professor'
            expect(u2.ai_endowed_title).to eq 'Distinguished Professor'
            expect(u2.orcid_identifier).to be_nil
            expect(u2.ai_alt_name).to be_nil
            expect(u2.ai_building).to eq 'FREAR SO BL'
            expect(u2.ai_room_number).to eq '431S'
            expect(u2.ai_office_area_code).to eq 814
            expect(u2.ai_office_phone_1).to eq 789
            expect(u2.ai_office_phone_2).to eq 152
            expect(u2.ai_fax_area_code).to be_nil
            expect(u2.ai_fax_1).to be_nil
            expect(u2.ai_fax_2).to be_nil
            expect(u2.ai_google_scholar).to eq 'gs2'
            expect(u2.ai_website).to eq 'myresearch.net'
            expect(u2.ai_bio).to eq 'bio2'

            expect(u3.first_name).to eq 'Jill'
            expect(u3.middle_name).to eq 'C'
            expect(u3.last_name).to eq 'Test'
            expect(u3.penn_state_identifier).to eq '978001402'
            expect(u3.activity_insight_identifier).to eq '2081288'
            expect(u3.ai_title).to be_nil
            expect(u3.ai_rank).to eq 'Research Associate'
            expect(u3.ai_endowed_title).to eq 'Special Title'
            expect(u3.orcid_identifier).to be_nil
            expect(u3.ai_alt_name).to eq 'J. C. Test'
            expect(u3.ai_building).to be_nil
            expect(u3.ai_room_number).to be_nil
            expect(u3.ai_office_area_code).to be_nil
            expect(u3.ai_office_phone_1).to be_nil
            expect(u3.ai_office_phone_2).to be_nil
            expect(u3.ai_fax_area_code).to eq 814
            expect(u3.ai_fax_1).to eq 555
            expect(u3.ai_fax_2).to eq 5555
            expect(u3.ai_google_scholar).to eq 'gs3'
            expect(u3.ai_website).to be_nil
            expect(u3.ai_bio).to eq 'bio3'
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