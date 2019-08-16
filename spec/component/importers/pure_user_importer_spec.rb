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
          expect(u1.scopus_h_index).to eq 15

          expect(u2.first_name).to eq 'Bob'
          expect(u2.middle_name).to eq 'B'
          expect(u2.last_name).to eq 'Testuser'
          expect(u2.pure_uuid).to eq 'a9ea5e62-9b39-4281-a759-e1c58f0ec582'
          expect(u2.scopus_h_index).to eq 21

          expect(u3.first_name).to eq 'Jill'
          expect(u3.middle_name).to be_nil
          expect(u3.last_name).to eq 'Test'
          expect(u3.pure_uuid).to eq '0177f1b1-bf3c-4f8d-af2a-10fe0034754c'
          expect(u3.scopus_h_index).to eq 2
        end

        context "when no organizations exist in the database" do
          it "does not create any new organization memberships" do
            expect { importer.call }.not_to change { UserOrganizationMembership.count }
          end
        end

        context "when organizations that are referenced in the .json file exist in the database" do
          let!(:org1) { create :organization, pure_uuid: '937d604c-a16a-499d-80eb-bd6f931a343c',
                               parent: org1_parent }
          let!(:org2) { create :organization, pure_uuid: 'e99fcbec-818a-4b90-a04a-986d05696395' }
          let!(:org3) { create :organization, pure_uuid: '47bf26c5-18c0-45d1-8aab-9f4597321764' }

          let!(:org1_parent) { create :organization, parent: org1_parent_parent }
          let!(:org1_parent_parent) { create :organization }

          context "when no organization memberships already exist" do
            it "creates a new membership for each association described in the .json file" do
              expect { importer.call }.to change { UserOrganizationMembership.count }.by 5

              u1 = User.find_by(webaccess_id: 'sat1')
              u2 = User.find_by(webaccess_id: 'bbt2')

              m1 = UserOrganizationMembership.find_by(pure_identifier: '21279128')
              m2 = UserOrganizationMembership.find_by(pure_identifier: '21309545')
              m3 = UserOrganizationMembership.find_by(pure_identifier: '24766061')
              m4 = UserOrganizationMembership.find_by(organization: org1_parent, user: u1)
              m5 = UserOrganizationMembership.find_by(organization: org1_parent_parent, user: u1)

              expect(m1.user).to eq u1
              expect(m1.organization).to eq org1
              expect(m1.imported_from_pure).to eq true
              expect(m1.primary).to eq false
              expect(m1.position_title).to eq 'Associate Professor'
              expect(m1.started_on).to eq Date.new(1984, 8, 14)
              expect(m1.ended_on).to eq Date.new(1990, 8, 14)
              expect(m1.updated_by_user_at).to eq nil

              expect(m2.user).to eq u2
              expect(m2.organization).to eq org2
              expect(m2.imported_from_pure).to eq true
              expect(m2.primary).to eq false
              expect(m2.position_title).to eq 'Professor'
              expect(m2.started_on).to eq Date.new(1997, 9, 1)
              expect(m2.ended_on).to eq Date.new(2000, 1, 1)
              expect(m2.updated_by_user_at).to eq nil

              expect(m3.user).to eq u2
              expect(m3.organization).to eq org3
              expect(m3.imported_from_pure).to eq true
              expect(m3.primary).to eq false
              expect(m3.position_title).to eq 'Senior Associate Dean'
              expect(m3.started_on).to eq Date.new(1997, 9, 1)
              expect(m3.ended_on).to eq nil
              expect(m3.updated_by_user_at).to eq nil

              expect(m4.pure_identifier).to eq nil
              expect(m4.imported_from_pure).to eq true
              expect(m4.primary).to eq nil
              expect(m4.position_title).to eq nil
              expect(m4.started_on).to eq Date.new(1984, 8, 14)
              expect(m4.ended_on).to eq Date.new(1990, 8, 14)
              expect(m4.updated_by_user_at).to eq nil

              expect(m5.pure_identifier).to eq nil
              expect(m5.imported_from_pure).to eq true
              expect(m5.primary).to eq nil
              expect(m5.position_title).to eq nil
              expect(m5.started_on).to eq Date.new(1984, 8, 14)
              expect(m5.ended_on).to eq Date.new(1990, 8, 14)
              expect(m5.updated_by_user_at).to eq nil
            end
          end

          context "when organization memberships already exist for associations described in the .json file" do
            let!(:existing_membership) { create :user_organization_membership,
                                                pure_identifier: '24766061',
                                                user: other_user,
                                                organization: other_org,
                                                imported_from_pure: false,
                                                primary: true,
                                                position_title: 'Existing Title',
                                                started_on: Date.new(1900, 1, 1),
                                                ended_on: Date.new(2000, 1, 1) }
            let!(:user1) { create :user, webaccess_id: 'sat1' }
            let!(:existing_pure_parent_membership) { create :user_organization_membership,
                                                            user: user1,
                                                            organization: org1_parent,
                                                            imported_from_pure: true }
            let!(:other_existing_parent_membership) { create :user_organization_membership,
                                                             user: user1,
                                                             organization: org1_parent,
                                                             imported_from_pure: false }
            let!(:existing_parent_parent_membership) { create :user_organization_membership,
                                                              user: user1,
                                                              organization: org1_parent_parent,
                                                              imported_from_pure: false }
            let(:other_user) { create :user }
            let(:other_org) { create :organization }

            it "creates a new membership for each new association and updates the existing memberships" do
              expect { importer.call }.to change { UserOrganizationMembership.count }.by 3

              u1 = user1
              u2 = User.find_by(webaccess_id: 'bbt2')

              m1 = UserOrganizationMembership.find_by(pure_identifier: '21279128')
              m2 = UserOrganizationMembership.find_by(pure_identifier: '21309545')
              m3 = existing_membership.reload
              m4 = existing_pure_parent_membership.reload
              m5 = UserOrganizationMembership.find_by(organization: org1_parent_parent,
                                                      user: u1,
                                                      imported_from_pure: true)

              m6 = other_existing_parent_membership.reload
              m7 = existing_parent_parent_membership.reload

              # This membership was created from the data in the import.
              expect(m1.user).to eq u1
              expect(m1.organization).to eq org1
              expect(m1.imported_from_pure).to eq true
              expect(m1.primary).to eq false
              expect(m1.position_title).to eq 'Associate Professor'
              expect(m1.started_on).to eq Date.new(1984, 8, 14)
              expect(m1.ended_on).to eq Date.new(1990, 8, 14)
              expect(m1.updated_by_user_at).to eq nil

              # This membership was also created from the data in the import.
              expect(m2.user).to eq u2
              expect(m2.organization).to eq org2
              expect(m2.imported_from_pure).to eq true
              expect(m2.primary).to eq false
              expect(m2.position_title).to eq 'Professor'
              expect(m2.started_on).to eq Date.new(1997, 9, 1)
              expect(m2.ended_on).to eq Date.new(2000, 1, 1)
              expect(m2.updated_by_user_at).to eq nil

              # A membership with this Pure identifier already existed with different
              # data than the data in the import, so it was updated with the data in
              # the import.
              expect(m3.user).to eq u2
              expect(m3.organization).to eq org3
              expect(m3.imported_from_pure).to eq true
              expect(m3.primary).to eq false
              expect(m3.position_title).to eq 'Senior Associate Dean'
              expect(m3.started_on).to eq Date.new(1997, 9, 1)
              expect(m3.ended_on).to eq nil
              expect(m3.updated_by_user_at).to eq nil

              # An implicit membership for this same user and organization already existed after
              # being generated from a previous pure import because data in the previous
              # import defined a membership between this user and one of this organization's
              # children, so this membership was updated based on different data for the
              # same implicit membership in this import.
              expect(m4.pure_identifier).to eq nil
              expect(m4.imported_from_pure).to eq true
              expect(m4.primary).to eq nil
              expect(m4.position_title).to eq nil
              expect(m4.started_on).to eq Date.new(1984, 8, 14)
              expect(m4.ended_on).to eq Date.new(1990, 8, 14)
              expect(m4.updated_by_user_at).to eq nil

              # This implicit membership was created because data in this import defined a membership
              # between this user and one of this organization's children's children, and while
              # a membership between the same user and organization already existed, it was not
              # created by a previous Pure import.
              expect(m5.pure_identifier).to eq nil
              expect(m5.imported_from_pure).to eq true
              expect(m5.primary).to eq nil
              expect(m5.position_title).to eq nil
              expect(m5.started_on).to eq Date.new(1984, 8, 14)
              expect(m5.ended_on).to eq Date.new(1990, 8, 14)
              expect(m5.updated_by_user_at).to eq nil

              # These memberships already existed, and although they were between the same users
              # and organizations as a memberships that were implicit in this import data, they
              # were not updated because they were not created by a previous Pure import.
              expect(m6.pure_identifier).to eq nil
              expect(m6.imported_from_pure).to eq false
              expect(m6.user).to eq u1
              expect(m6.organization).to eq org1_parent
              expect(m6.primary).to eq nil
              expect(m6.position_title).to eq nil
              expect(m6.started_on).to eq nil
              expect(m6.ended_on).to eq nil
              expect(m6.updated_by_user_at).to eq nil

              expect(m7.pure_identifier).to eq nil
              expect(m7.imported_from_pure).to eq false
              expect(m7.user).to eq u1
              expect(m7.organization).to eq org1_parent_parent
              expect(m7.primary).to eq nil
              expect(m7.position_title).to eq nil
              expect(m7.started_on).to eq nil
              expect(m7.ended_on).to eq nil
              expect(m7.updated_by_user_at).to eq nil
            end
          end
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
                                      scopus_h_index: 79,
                                      updated_by_user_at: timestamp,
                                      activity_insight_identifier: ai_id }
        let(:ai_id) { nil }
        let(:timestamp) { nil }

        context "when the existing user has been updated by a human" do
          let(:timestamp) { Time.zone.now }
          it "creates new records for the new users and only updates some existing user data" do
            expect { importer.call }.to change { User.count }.by 2

            u1 = User.find_by(webaccess_id: 'sat1')
            u2 = User.find_by(webaccess_id: 'bbt2')
            u3 = User.find_by(webaccess_id: 'jct3')

            expect(u1.first_name).to eq 'Susan'
            expect(u1.middle_name).to eq 'A'
            expect(u1.last_name).to eq 'Tester'
            expect(u1.pure_uuid).to eq '9530a014-c29f-4081-88ae-b923dc919001'
            expect(u1.scopus_h_index).to eq 15

            expect(u2.first_name).to eq 'Robert'
            expect(u2.middle_name).to eq 'B'
            expect(u2.last_name).to eq 'Testuser'
            expect(u2.pure_uuid).to eq 'a9ea5e62-9b39-4281-a759-e1c58f0ec582'
            expect(u2.scopus_h_index).to eq 21

            expect(u3.first_name).to eq 'Jill'
            expect(u3.middle_name).to be_nil
            expect(u3.last_name).to eq 'Test'
            expect(u3.pure_uuid).to eq '0177f1b1-bf3c-4f8d-af2a-10fe0034754c'
            expect(u3.scopus_h_index).to eq 2
          end
        end

        context "when the existing user has been imported from Activity Insight" do
          let(:ai_id) { '12345678' }
          it "creates new records for the new users and only updates some existing user data" do
            expect { importer.call }.to change { User.count }.by 2

            u1 = User.find_by(webaccess_id: 'sat1')
            u2 = User.find_by(webaccess_id: 'bbt2')
            u3 = User.find_by(webaccess_id: 'jct3')

            expect(u1.first_name).to eq 'Susan'
            expect(u1.middle_name).to eq 'A'
            expect(u1.last_name).to eq 'Tester'
            expect(u1.pure_uuid).to eq '9530a014-c29f-4081-88ae-b923dc919001'
            expect(u1.scopus_h_index).to eq 15

            expect(u2.first_name).to eq 'Robert'
            expect(u2.middle_name).to eq 'B'
            expect(u2.last_name).to eq 'Testuser'
            expect(u2.pure_uuid).to eq 'a9ea5e62-9b39-4281-a759-e1c58f0ec582'
            expect(u2.scopus_h_index).to eq 21

            expect(u3.first_name).to eq 'Jill'
            expect(u3.middle_name).to be_nil
            expect(u3.last_name).to eq 'Test'
            expect(u3.pure_uuid).to eq '0177f1b1-bf3c-4f8d-af2a-10fe0034754c'
            expect(u3.scopus_h_index).to eq 2
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
            expect(u1.scopus_h_index).to eq 15

            expect(u2.first_name).to eq 'Bob'
            expect(u2.middle_name).to eq 'B'
            expect(u2.last_name).to eq 'Testuser'
            expect(u2.pure_uuid).to eq 'a9ea5e62-9b39-4281-a759-e1c58f0ec582'
            expect(u2.scopus_h_index).to eq 21

            expect(u3.first_name).to eq 'Jill'
            expect(u3.middle_name).to be_nil
            expect(u3.last_name).to eq 'Test'
            expect(u3.pure_uuid).to eq '0177f1b1-bf3c-4f8d-af2a-10fe0034754c'
            expect(u3.scopus_h_index).to eq 2
          end
        end
      end
    end
  end
end