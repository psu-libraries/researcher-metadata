require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = nil

describe 'the users table', type: :model do
  subject(:user) { User.new }
  it { is_expected.to have_db_column(:activity_insight_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:first_name).of_type(:string) }
  it { is_expected.to have_db_column(:middle_name).of_type(:string) }
  it { is_expected.to have_db_column(:last_name).of_type(:string) }
  it { is_expected.to have_db_column(:webaccess_id).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:penn_state_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:is_admin).of_type(:boolean).with_options(default: false) }
  it { is_expected.to have_db_column(:pure_uuid).of_type(:string) }
  it { is_expected.to have_db_column(:scopus_h_index).of_type(:integer) }
  it { is_expected.to have_db_column(:show_all_publications).of_type(:boolean).with_options(default: true) }
  it { is_expected.to have_db_column(:show_all_contracts).of_type(:boolean).with_options(default: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_by_user_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:ai_title).of_type(:string) }
  it { is_expected.to have_db_column(:ai_rank).of_type(:string) }
  it { is_expected.to have_db_column(:ai_endowed_title).of_type(:string) }
  it { is_expected.to have_db_column(:orcid_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:ai_alt_name).of_type(:string) }
  it { is_expected.to have_db_column(:ai_building).of_type(:string) }
  it { is_expected.to have_db_column(:ai_room_number).of_type(:string) }
  it { is_expected.to have_db_column(:ai_office_area_code).of_type(:integer) }
  it { is_expected.to have_db_column(:ai_office_phone_1).of_type(:integer) }
  it { is_expected.to have_db_column(:ai_office_phone_2).of_type(:integer) }
  it { is_expected.to have_db_column(:ai_fax_area_code).of_type(:integer) }
  it { is_expected.to have_db_column(:ai_fax_1).of_type(:integer) }
  it { is_expected.to have_db_column(:ai_fax_2).of_type(:integer) }
  it { is_expected.to have_db_column(:ai_google_scholar).of_type(:text) }
  it { is_expected.to have_db_column(:ai_website).of_type(:text) }
  it { is_expected.to have_db_column(:ai_bio).of_type(:text) }
  it { is_expected.to have_db_column(:ai_teaching_interests).of_type(:text) }
  it { is_expected.to have_db_column(:ai_research_interests).of_type(:text) }
  it { is_expected.to have_db_column(:orcid_access_token).of_type(:string) }
  it { is_expected.to have_db_column(:orcid_refresh_token).of_type(:string) }
  it { is_expected.to have_db_column(:orcid_access_token_scope).of_type(:string) }
  it { is_expected.to have_db_column(:orcid_access_token_expires_in).of_type(:integer) }
  it { is_expected.to have_db_column(:authenticated_orcid_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:open_access_notification_sent_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:uid).of_type(:string) }
  it { is_expected.to have_db_column(:provider).of_type(:string) }

  it { is_expected.to have_db_index(:activity_insight_identifier).unique(true) }
  it { is_expected.to have_db_index(:pure_uuid).unique(true) }
  it { is_expected.to have_db_index(:webaccess_id).unique(true) }
  it { is_expected.to have_db_index(:penn_state_identifier).unique(true) }
  it { is_expected.to have_db_index(:orcid_identifier).unique(true) }
  it { is_expected.to have_db_index(:first_name) }
  it { is_expected.to have_db_index(:middle_name) }
  it { is_expected.to have_db_index(:last_name) }
end

describe User, type: :model do
  subject(:user) { User.new }

  it_behaves_like "an application record"

  describe 'associations' do
    it { is_expected.to have_many(:authorships) }
    it { is_expected.to have_many(:publications).through(:authorships) }
    it { is_expected.to have_many(:user_contracts) }
    it { is_expected.to have_many(:contracts).through(:user_contracts) }
    it { is_expected.to have_many(:presentation_contributions) }
    it { is_expected.to have_many(:presentations).through(:presentation_contributions) }
    it { is_expected.to have_many(:committee_memberships).inverse_of(:user) }
    it { is_expected.to have_many(:etds).through(:committee_memberships) }
    it { is_expected.to have_many(:news_feed_items) }
    it { is_expected.to have_many(:user_performances) }
    it { is_expected.to have_many(:performances).through(:user_performances) }
    it { is_expected.to have_many(:user_organization_memberships).inverse_of(:user) }
    it { is_expected.to have_many(:organizations).through(:user_organization_memberships) }
    it { is_expected.to have_many(:managed_organizations).class_name(:Organization).with_foreign_key(:owner_id) }
    it { is_expected.to have_many(:managed_users).through(:managed_organizations).source(:users) }
    it { is_expected.to have_many(:education_history_items) }
    it { is_expected.to have_many(:researcher_funds).inverse_of(:user) }
    it { is_expected.to have_many(:grants).through(:researcher_funds) }
    it { is_expected.to have_many(:external_publication_waivers) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:webaccess_id) }

    context "given an otherwise valid record" do
      subject { User.new(webaccess_id: 'abc123') }
      it { is_expected.to validate_uniqueness_of(:webaccess_id).case_insensitive }
      it { is_expected.to validate_uniqueness_of(:activity_insight_identifier).allow_nil }
      it { is_expected.to validate_uniqueness_of(:pure_uuid).allow_nil }
      it { is_expected.to validate_uniqueness_of(:penn_state_identifier).allow_nil }
    end
  end

  it { is_expected.to accept_nested_attributes_for(:user_organization_memberships).allow_destroy(true) }

  describe "saving a value for webaccess_id" do
    let(:u) { create :user, webaccess_id: wa_id }
    context "when the value contains uppercase letters" do
      let(:wa_id) { 'ABC123' }
      it "converts letters to lowercase before saving" do
        expect(u.webaccess_id).to eq 'abc123'
      end
    end
    context "when the value does not contain uppercase letters" do
      let(:wa_id) { 'xyz789' }
      it "saves the string without modifying it" do
        expect(u.webaccess_id).to eq 'xyz789'
      end
    end
  end

  describe "saving a value for penn_state_identifier" do
    let(:u) { create :user, penn_state_identifier: psu_id }
    context "when given nil" do
      let(:psu_id) { nil }
      it "saves the value as nil" do
        expect(u.penn_state_identifier).to eq nil
      end
    end
    context "when given an empty string" do
      let(:psu_id) { '' }
      it "saves the value as nil" do
        expect(u.penn_state_identifier).to eq nil
      end
    end
    context "when given a blank string" do
      let(:psu_id) { ' ' }
      it "saves the value as nil" do
        expect(u.penn_state_identifier).to eq nil
      end
    end
    context "when given a non-blank string" do
      let(:psu_id) { 'a' }
      it "saves the value of the string" do
        expect(u.penn_state_identifier).to eq 'a'
      end
    end
  end

  describe "saving a value for pure_uuid" do
    let(:u) { create :user, pure_uuid: pure_id }
    context "when given nil" do
      let(:pure_id) { nil }
      it "saves the value as nil" do
        expect(u.pure_uuid).to eq nil
      end
    end
    context "when given an empty string" do
      let(:pure_id) { '' }
      it "saves the value as nil" do
        expect(u.pure_uuid).to eq nil
      end
    end
    context "when given a blank string" do
      let(:pure_id) { ' ' }
      it "saves the value as nil" do
        expect(u.pure_uuid).to eq nil
      end
    end
    context "when given a non-blank string" do
      let(:pure_id) { 'a' }
      it "saves the value of the string" do
        expect(u.pure_uuid).to eq 'a'
      end
    end
  end

  describe "saving a value for activity_insight_identifier" do
    let(:u) { create :user, activity_insight_identifier: ai_id }
    context "when given nil" do
      let(:ai_id) { nil }
      it "saves the value as nil" do
        expect(u.activity_insight_identifier).to eq nil
      end
    end
    context "when given an empty string" do
      let(:ai_id) { '' }
      it "saves the value as nil" do
        expect(u.activity_insight_identifier).to eq nil
      end
    end
    context "when given a blank string" do
      let(:ai_id) { ' ' }
      it "saves the value as nil" do
        expect(u.activity_insight_identifier).to eq nil
      end
    end
    context "when given a non-blank string" do
      let(:ai_id) { 'a' }
      it "saves the value of the string" do
        expect(u.activity_insight_identifier).to eq 'a'
      end
    end
  end

  describe "deleting a user with authorships" do
    let(:u) { create :user }
    let!(:a) { create :authorship, user: u}
    it "also deletes the user's authorships" do
      u.destroy
      expect { a.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "deleting a user with user_contracts" do
    let(:u) { create :user }
    let!(:uc) { create :user_contract, user: u}
    it "also deletes the user's user_contracts" do
      u.destroy
      expect { uc.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "deleting a user with organization memberships" do
    let(:u) { create :user }
    let!(:m) { create :user_organization_membership, user: u}
    it "also deletes the user's memberships" do
      u.destroy
      expect { m.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "deleting a user with researcher funds" do
    let(:u) { create :user }
    let!(:f) { create :researcher_fund, user: u}
    it "also deletes the user's researcher_funds" do
      u.destroy
      expect { f.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '.from_omniauth' do
    xit
  end

  describe '.find_all_by_wos_pub' do
    let(:wp) { double 'Web of Science publication',
                      orcids: ['orcid123', 'orcid456', 'orcid789'],
                      author_names: [an1, an2, an3, an4] }
    let(:an1) { double 'author name 1',
                       first_name: 'First1',
                       first_initial: nil,
                       middle_name: 'Middle1',
                       middle_initial: nil,
                       last_name: 'Last1' }
    let(:an2) { double 'author name 2',
                       first_name: 'First2',
                       first_initial: nil,
                       middle_name: nil,
                       middle_initial: 'M',
                       last_name: 'Last2' }
    let(:an3) { double 'author name 3',
                       first_name: 'First3',
                       first_initial: nil,
                       middle_name: nil,
                       middle_initial: nil,
                       last_name: 'Last3' }
    let(:an4) { double 'author name 4',
                       first_name: nil,
                       first_initial: 'F',
                       middle_name: nil,
                       middle_initial: 'M',
                       last_name: 'Last4' }
    context "when no users match the given Web of Science data" do
      it "returns an empty array" do
        expect(User.find_all_by_wos_pub(wp)).to eq []
      end
    end
    context "when there are users that match the given Web of Science data" do
      let!(:u1) { create :user, orcid_identifier: 'https://orcid.org/orcid123' }
      let!(:u2) { create :user, orcid_identifier: 'https://orcid.org/orcid456' }
      let!(:u3) { create :user, first_name: 'First1', middle_name: 'Middle1', last_name: 'Last1' }
      let!(:u4) { create :user, first_name: 'First2', middle_name: 'Middle2', last_name: 'Last2' }
      let!(:u5) { create :user, first_name: 'First2', middle_name: 'm', last_name: 'Last2' }
      let!(:u6) { create :user, first_name: 'First3', middle_name: 'Middle3', last_name: 'Last3' }
      let!(:u7) { create :user, first_name: 'First4', middle_name: 'Middle4', last_name: 'Last4' }
      let!(:u8) { create :user, first_name: 'f', middle_name: 'm', last_name: 'Last4' }
      let!(:u9) { create :user, first_name: 'f', middle_name: 'm', last_name: 'Last4', orcid_identifier: 'https://orcid.org/orcid789' }
      let!(:u10) { create :user, first_name: 'First1', middle_name: nil, last_name: 'Last1' }
      let!(:u11) { create :user, first_name: 'First1', middle_name: 'M', last_name: 'Last1' }
      let!(:u12) { create :user, first_name: 'First2', middle_name: nil, last_name: 'Last2' }
      let!(:u13) { create :user, first_name: 'First2', middle_name: 'AMiddle2', last_name: 'Last2' }
      before do
        create :user, first_name: 'Other', middle_name: 'Middle1', last_name: 'Last1'
        create :user, first_name: 'First1', middle_name: 'Middle1', last_name: 'Other'
        create :user, first_name: 'F', middle_name: 'M', last_name: 'Last1'

        create :user, first_name: 'Other', middle_name: 'M', last_name: 'Other'
        create :user, first_name: 'First2', middle_name: 'M', last_name: 'Other'
        create :user, first_name: 'Other', middle_name: 'M', last_name: 'Last2'

        create :user, first_name: 'AFirst4', middle_name: 'Middle4', last_name: 'Last4'
        create :user, first_name: 'First4', middle_name: 'AMiddle4', last_name: 'Last4'
        create :user, first_name: 'Other', middle_name: 'Middle4', last_name: 'Last4'
        create :user, first_name: 'First4', middle_name: 'Other', last_name: 'Last4'
        create :user, first_name: 'First4', middle_name: 'Middle4', last_name: 'Other'
      end
      it "returns one instance of each matching user" do
        expect(User.find_all_by_wos_pub(wp)).to match_array [u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12, u13]
      end
    end
  end

  describe '.find_confirmed_by_wos_pub' do
    let(:wp) { double 'Web of Science publication',
                      orcids: ['orcid123', 'orcid456', 'orcid789'] }

    context "when no users match the given Web of Science data" do
      it "returns an empty array" do
        expect(User.find_confirmed_by_wos_pub(wp)).to eq []
      end
    end
    context "when there are users that match the given Web of Science data by ORCID" do
      let!(:u1) { create :user, orcid_identifier: 'https://orcid.org/orcid123' }
      let!(:u2) { create :user, orcid_identifier: 'https://orcid.org/orcid456' }
      before { create :user, orcid_identifier: nil }
      it "returns one instance of each matching user" do
        expect(User.find_confirmed_by_wos_pub(wp)).to match_array [u1, u2]
      end
    end
  end

  describe '.find_by_nsf_grant' do
    let!(:u1) { create :user, first_name: 'Susan', last_name: 'Tester', webaccess_id: 'sat123' }
    let!(:u2) { create :user, first_name: 'Robert', last_name: 'Testuser', webaccess_id: 'rbt456' }
    let!(:u3) { create :user, first_name: 'Other', last_name: 'User', webaccess_id: 'ou111' }

    context "when given a grant with investigators that match existing users" do
      let(:i1) { double 'investigator', first_name: 'Nick', last_name: 'Name', psu_email_name: 'rbt456' } 
      let(:i2) { double 'investigator', first_name: 'Susan', last_name: 'Tester', psu_email_name: nil } 
      let(:grant) { double 'grant', investigators: [i1, i2] }
      it "returns the existing users" do
        expect(User.find_by_nsf_grant(grant)).to match_array [u1, u2]
      end
    end
  end

  describe '.needs_open_access_notification' do
    # Users who meet all of the criteria to receive an email
    let!(:email_user_1) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'email_user_1' }
    let!(:eu_mem_1) { create :user_organization_membership,
                             user: email_user_1,
                             started_on: Date.new(2019, 1, 1),
                             ended_on: nil }
    let!(:eu_pub_1) { create :publication, published_on: Date.new(2020, 7, 1) }
    let!(:eu_auth_1) { create :authorship,
                              user: email_user_1,
                              publication: eu_pub_1,
                              confirmed: true }

    let!(:email_user_2) { create :user, open_access_notification_sent_at: nil, first_name: 'email_user_2' }
    let!(:eu_mem_2) { create :user_organization_membership,
                              user: email_user_2,
                              started_on: Date.new(2019, 1, 1),
                              ended_on: nil }
    let!(:eu_pub_2) { create :publication, published_on: Date.new(2020, 7, 1) }
    let!(:eu_auth_2) { create :authorship,
                              user: email_user_2,
                              publication: eu_pub_2,
                              confirmed: true }

    let!(:email_user_3) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'email_user_3' }
    let!(:eu_mem_3) { create :user_organization_membership,
                              user: email_user_3,
                              started_on: Date.new(2019, 1, 1),
                              ended_on: Date.new(2020, 7, 2) }
    let!(:eu_pub_3) { create :publication, published_on: Date.new(2020, 7, 1) }
    let!(:eu_auth_3) { create :authorship,
                              user: email_user_3,
                              publication: eu_pub_3,
                              confirmed: true }

    let!(:email_user_4) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'email_user_4' }
    let!(:eu_mem_4) { create :user_organization_membership,
                             user: email_user_4,
                             started_on: Date.new(2019, 1, 1),
                             ended_on: nil }
    let!(:eu_pub_4) { create :publication, 
                             published_on: Date.new(2020, 7, 1),
                             open_access_url: '',
                             user_submitted_open_access_url: '' }
    let!(:eu_auth_4) { create :authorship,
                              user: email_user_4,
                              publication: eu_pub_4,
                              confirmed: true }    

    # Filtered out due to recent notification timestamp
    let!(:other_user_1) { create :user, open_access_notification_sent_at: 1.month.ago, first_name: 'other_user_1' }
    let!(:ou_mem_1) { create :user_organization_membership,
                             user: other_user_1,
                             started_on: Date.new(2019, 1, 1),
                             ended_on: nil }
    let!(:ou_pub_1) { create :publication, published_on: Date.new(2020, 7, 1) }
    let!(:ou_auth_1) { create :authorship,
                              user: other_user_1,
                              publication: ou_pub_1,
                              confirmed: true }

    # Filtered out due to not having an organization membership
    let!(:other_user_2) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'other_user_2' }
    let!(:ou_pub_2) { create :publication, published_on: Date.new(2020, 7, 1) }
    let!(:ou_auth_2) { create :authorship,
                              user: other_user_2,
                              publication: ou_pub_2,
                              confirmed: true }

    # Filtered out due to publication being published outside of org membership
    let!(:other_user_3) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'other_user_3' }
    let!(:ou_mem_3) { create :user_organization_membership,
                             user: other_user_3,
                             started_on: Date.new(2020, 8, 1),
                             ended_on: nil }
    let!(:ou_pub_3) { create :publication, published_on: Date.new(2020, 7, 1) }
    let!(:ou_auth_3) { create :authorship,
                              user: other_user_3,
                              publication: ou_pub_3,
                              confirmed: true }

    # Filtered out due to publication being published before open access policy
    let!(:other_user_4) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'other_user_4' }
    let!(:ou_mem_4) { create :user_organization_membership,
                             user: other_user_4,
                             started_on: Date.new(2019, 1, 1),
                             ended_on: nil }
    let!(:ou_pub_4) { create :publication, published_on: Date.new(2020, 6, 30) }
    let!(:ou_auth_4) { create :authorship,
                              user: other_user_4,
                              publication: ou_pub_4,
                              confirmed: true }

    # Filtered out due to authorship not being confirmed
    let!(:other_user_5) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'other_user_5' }
    let!(:ou_mem_5) { create :user_organization_membership,
                             user: other_user_5,
                             started_on: Date.new(2019, 1, 1),
                             ended_on: nil }
    let!(:ou_pub_5) { create :publication, published_on: Date.new(2020, 7, 1) }
    let!(:ou_auth_5) { create :authorship,
                              user: other_user_5,
                              publication: ou_pub_5,
                              confirmed: false }

    # Filtered out due to open_access_url being present
    let!(:other_user_6) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'other_user_6' }
    let!(:ou_mem_6) { create :user_organization_membership,
                             user: other_user_6,
                             started_on: Date.new(2019, 1, 1),
                             ended_on: nil }
    let!(:ou_pub_6) { create :publication, published_on: Date.new(2020, 7, 1), open_access_url: 'a_url' }
    let!(:ou_auth_6) { create :authorship,
                              user: other_user_6,
                              publication: ou_pub_6,
                              confirmed: true }

    # Filtered out due to user_submitted_open_access_url being present
    let!(:other_user_7) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'other_user_7' }
    let!(:ou_mem_7) { create :user_organization_membership,
                             user: other_user_7,
                             started_on: Date.new(2019, 1, 1),
                             ended_on: nil }
    let!(:ou_pub_7) { create :publication, published_on: Date.new(2020, 7, 1), user_submitted_open_access_url: 'a_url' }
    let!(:ou_auth_7) { create :authorship,
                              user: other_user_7,
                              publication: ou_pub_7,
                              confirmed: true }

    # Filtered out due to scholarsphere upload timestamp being present
    let!(:other_user_8) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'other_user_8' }
    let!(:ou_mem_8) { create :user_organization_membership,
                             user: other_user_8,
                             started_on: Date.new(2019, 1, 1),
                             ended_on: nil }
    let!(:ou_pub_8) { create :publication, published_on: Date.new(2020, 7, 1) }
    let!(:ou_auth_8) { create :authorship,
                              user: other_user_8,
                              publication: ou_pub_8,
                              confirmed: true,
                              scholarsphere_uploaded_at: 1.day.ago }

    # Filtered out due to scholarsphere upload timestamp being present on another authorship
    let!(:other_user_9) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'other_user_9' }
    let!(:ou_mem_9) { create :user_organization_membership,
                             user: other_user_9,
                             started_on: Date.new(2019, 1, 1),
                             ended_on: nil }
    let!(:ou_pub_9) { create :publication, published_on: Date.new(2020, 7, 1) }
    let!(:ou_auth_9) { create :authorship,
                              user: other_user_9,
                              publication: ou_pub_9,
                              confirmed: true }
    let!(:another_authorship_9) { create :authorship,
                                         publication: ou_pub_9,
                                         scholarsphere_uploaded_at: 1.day.ago }

    # Filtered out due to presence of open access waiver
    let!(:other_user_10) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'other_user_10' }
    let!(:ou_mem_10) { create :user_organization_membership,
                              user: other_user_10,
                              started_on: Date.new(2019, 1, 1),
                              ended_on: nil }
    let!(:ou_pub_10) { create :publication, published_on: Date.new(2020, 7, 1) }
    let!(:ou_auth_10) { create :authorship,
                               user: other_user_10,
                               publication: ou_pub_10,
                               confirmed: true }
    let!(:waiver_10) { create :internal_publication_waiver, authorship: ou_auth_10 }

    # Filtered out due to presence of open access waiver on another authorship
    let!(:other_user_11) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'other_user_11' }
    let!(:ou_mem_11) { create :user_organization_membership,
                              user: other_user_11,
                              started_on: Date.new(2019, 1, 1),
                              ended_on: nil }
    let!(:ou_pub_11) { create :publication, published_on: Date.new(2020, 7, 1) }
    let!(:ou_auth_11) { create :authorship,
                               user: other_user_11,
                               publication: ou_pub_11,
                               confirmed: true }
    let!(:another_authorship_11) { create :authorship, publication: ou_pub_11 }
    let!(:waiver_11) { create :internal_publication_waiver, authorship: another_authorship_11 }

    # Filtered out due to publication being hidden
    let!(:other_user_12) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'other_user_12' }
    let!(:ou_mem_12) { create :user_organization_membership,
                             user: other_user_12,
                             started_on: Date.new(2019, 1, 1),
                             ended_on: nil }
    let!(:ou_pub_12) { create :publication, published_on: Date.new(2020, 7, 1), visible: false }
    let!(:ou_auth_12) { create :authorship,
                              user: other_user_12,
                              publication: ou_pub_12,
                              confirmed: true }

    # Filtered out due to publication not being a journal article
    let!(:other_user_13) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'other_user_13' }
    let!(:ou_mem_13) { create :user_organization_membership,
                             user: other_user_13,
                             started_on: Date.new(2019, 1, 1),
                             ended_on: nil }
    let!(:ou_pub_13) { create :publication, published_on: Date.new(2020, 7, 1), publication_type: 'Book' }
    let!(:ou_auth_13) { create :authorship,
                              user: other_user_13,
                              publication: ou_pub_13,
                              confirmed: true }

    # Filtered out due to scholarsphere_open_access_url being present
    let!(:other_user_14) { create :user, open_access_notification_sent_at: 1.year.ago, first_name: 'other_user_14' }
    let!(:ou_mem_14) { create :user_organization_membership,
                              user: other_user_14,
                              started_on: Date.new(2019, 1, 1),
                              ended_on: nil }
    let!(:ou_pub_14) { create :publication, published_on: Date.new(2020, 7, 1), scholarsphere_open_access_url: 'a_url' }
    let!(:ou_auth_14) { create :authorship,
                              user: other_user_14,
                              publication: ou_pub_14,
                              confirmed: true }

    it "returns only users who should currently receive an email reminder about open access publications" do
      expect(User.needs_open_access_notification).to match_array [email_user_1,
                                                                  email_user_2,
                                                                  email_user_3,
                                                                  email_user_4]
    end
  end

  describe '#old_potential_open_access_publications' do
    let!(:user) { create :user }
    let!(:org) { create :organization }
    let!(:membership) { create :user_organization_membership,
                               user: user,
                               organization: org,
                               started_on: Date.new(2000, 1, 1),
                               ended_on: Date.new(2020, 8, 1) }
    
    # Publications that meet the criteria for an open access reminder
    let!(:potential_pub_1) { create :publication,
                                    published_on: Date.new(2020, 7, 1) }
    let!(:p_auth_1) { create :authorship,
                             user: user,
                             publication: potential_pub_1,
                             confirmed: true,
                             open_access_notification_sent_at: 1.month.ago }

    let!(:potential_pub_2) { create :publication,
                                    published_on: Date.new(2020, 7, 1),
                                    open_access_url: '',
                                    user_submitted_open_access_url: '' }
    let!(:p_auth_2) { create :authorship,
                             user: user,
                             publication: potential_pub_2,
                             confirmed: true,
                             open_access_notification_sent_at: 1.month.ago }

    # Filtered out due to being published before open access policy
    let!(:other_pub_1) { create :publication,
                                published_on: Date.new(2020, 6, 30) }
    let!(:o_auth_1) { create :authorship,
                             user: user,
                             publication: other_pub_1,
                             confirmed: true,
                             open_access_notification_sent_at: 1.month.ago }

    # Filtered out due to presence of open_access_url
    let!(:other_pub_5) { create :publication,
                                published_on: Date.new(2020, 7, 1),
                                open_access_url: 'a_url' }
    let!(:o_auth_5) { create :authorship,
                             user: user,
                             publication: other_pub_5,
                             confirmed: true,
                             open_access_notification_sent_at: 1.month.ago }

    # Filtered out due to presence of user_submitted_open_access_url
    let!(:other_pub_6) { create :publication,
                                published_on: Date.new(2020, 7, 1),
                                user_submitted_open_access_url: 'a_url' }
    let!(:o_auth_6) { create :authorship,
                             user: user,
                             publication: other_pub_6,
                             confirmed: true,
                             open_access_notification_sent_at: 1.month.ago }

    # Filtered out due to presence of Scholarsphere upload timestamp on authorship
    let!(:other_pub_7) { create :publication,
                                published_on: Date.new(2020, 7, 1) }
    let!(:o_auth_7) { create :authorship,
                             user: user,
                             publication: other_pub_7,
                             confirmed: true,
                             scholarsphere_uploaded_at: 1.day.ago,
                             open_access_notification_sent_at: 1.month.ago }

    # Filtered out due to presence of Scholarsphere upload timestamp on another authorship
    let!(:other_pub_8) { create :publication,
                                published_on: Date.new(2020, 7, 1) }
    let!(:o_auth_8) { create :authorship,
                             user: user,
                             publication: other_pub_8,
                             confirmed: true,
                             open_access_notification_sent_at: 1.month.ago }
    let!(:another_auth_8) { create :authorship,
                                   publication: other_pub_8,
                                   scholarsphere_uploaded_at: 1.day.ago }

    # Filtered out due to presence of open access waiver
    let!(:other_pub_9) { create :publication,
                                published_on: Date.new(2020, 7, 1) }
    let!(:o_auth_9) { create :authorship,
                             user: user,
                             publication: other_pub_9,
                             confirmed: true,
                             open_access_notification_sent_at: 1.month.ago }
    let!(:waiver_9) { create :internal_publication_waiver, authorship: o_auth_9 }

    # Filtered out due to presence of open access waiver on another authorship
    let!(:other_pub_10) { create :publication,
                                 published_on: Date.new(2020, 7, 1) }
    let!(:o_auth_10) { create :authorship,
                              user: user,
                              publication: other_pub_10,
                              confirmed: true,
                              open_access_notification_sent_at: 1.month.ago }
    let!(:another_auth_10) { create :authorship,
                                    publication: other_pub_10 }
    let!(:waiver_10) { create :internal_publication_waiver, authorship: another_auth_10 }

    # Filtered out due to authorship not being confirmed
    let!(:other_pub_11) { create :publication,
                                 published_on: Date.new(2020, 7, 1) }
    let!(:o_auth_11) { create :authorship,
                              user: user,
                              publication: other_pub_11,
                              confirmed: false,
                              open_access_notification_sent_at: 1.month.ago }

    # Filtered out due to the user having never been notified about the publication before
    let!(:other_pub_12) { create :publication,
                                 published_on: Date.new(2020, 7, 1) }
    let!(:o_auth_12) { create :authorship,
                              user: user,
                              publication: other_pub_12,
                              confirmed: true,
                              open_access_notification_sent_at: nil }

    # Filtered out due to the publication being hidden
    let!(:other_pub_13) { create :publication,
                                 published_on: Date.new(2020, 7, 1),
                                 visible: false }
    let!(:o_auth_13) { create :authorship,
                              user: user,
                              publication: other_pub_13,
                              confirmed: true,
                              open_access_notification_sent_at: 1.month.ago }

    # Filtered out due to the publication not being a journal article
    let!(:other_pub_14) { create :publication,
                                 published_on: Date.new(2020, 7, 1),
                                 visible: true,
                                 publication_type: 'Book' }
    let!(:o_auth_14) { create :authorship,
                              user: user,
                              publication: other_pub_14,
                              confirmed: true,
                              open_access_notification_sent_at: 1.month.ago }

    it "returns the user's recent publications that they've been notified about before that don't have any associated open access information" do
      expect(user.old_potential_open_access_publications).to match_array [potential_pub_1,
                                                                          potential_pub_2]
    end
  end

  describe '#new_potential_open_access_publications' do
    let!(:user) { create :user }
    let!(:org) { create :organization }
    let!(:membership) { create :user_organization_membership,
                               user: user,
                               organization: org,
                               started_on: Date.new(2000, 1, 1),
                               ended_on: Date.new(2020, 8, 1) }
    
    # Publications that meet the criteria for an open access reminder
    let!(:potential_pub_1) { create :publication,
                                    published_on: Date.new(2020, 7, 1) }
    let!(:p_auth_1) { create :authorship,
                             user: user,
                             publication: potential_pub_1,
                             confirmed: true,
                             open_access_notification_sent_at: nil }

    let!(:potential_pub_2) { create :publication,
                                    published_on: Date.new(2020, 7, 1),
                                    open_access_url: '',
                                    user_submitted_open_access_url: '' }
    let!(:p_auth_2) { create :authorship,
                             user: user,
                             publication: potential_pub_2,
                             confirmed: true,
                             open_access_notification_sent_at: nil }

    # Filtered out due to being published before open access policy
    let!(:other_pub_1) { create :publication,
                                published_on: Date.new(2020, 6, 30) }
    let!(:o_auth_1) { create :authorship,
                             user: user,
                             publication: other_pub_1,
                             confirmed: true }

    # Filtered out due to presence of open_access_url
    let!(:other_pub_5) { create :publication,
                                published_on: Date.new(2020, 7, 1),
                                open_access_url: 'a_url' }
    let!(:o_auth_5) { create :authorship,
                             user: user,
                             publication: other_pub_5,
                             confirmed: true }

    # Filtered out due to presence of user_submitted_open_access_url
    let!(:other_pub_6) { create :publication,
                                published_on: Date.new(2020, 7, 1),
                                user_submitted_open_access_url: 'a_url' }
    let!(:o_auth_6) { create :authorship,
                             user: user,
                             publication: other_pub_6,
                             confirmed: true }

    # Filtered out due to presence of Scholarsphere upload timestamp on authorship
    let!(:other_pub_7) { create :publication,
                                published_on: Date.new(2020, 7, 1) }
    let!(:o_auth_7) { create :authorship,
                             user: user,
                             publication: other_pub_7,
                             confirmed: true,
                             scholarsphere_uploaded_at: 1.day.ago }

    # Filtered out due to presence of Scholarsphere upload timestamp on another authorship
    let!(:other_pub_8) { create :publication,
                                published_on: Date.new(2020, 7, 1) }
    let!(:o_auth_8) { create :authorship,
                             user: user,
                             publication: other_pub_8,
                             confirmed: true }
    let!(:another_auth_8) { create :authorship,
                                   publication: other_pub_8,
                                   scholarsphere_uploaded_at: 1.day.ago }

    # Filtered out due to presence of open access waiver
    let!(:other_pub_9) { create :publication,
                                published_on: Date.new(2020, 7, 1) }
    let!(:o_auth_9) { create :authorship,
                             user: user,
                             publication: other_pub_9,
                             confirmed: true }
    let!(:waiver_9) { create :internal_publication_waiver, authorship: o_auth_9 }

    # Filtered out due to presence of open access waiver on another authorship
    let!(:other_pub_10) { create :publication,
                                 published_on: Date.new(2020, 7, 1) }
    let!(:o_auth_10) { create :authorship,
                              user: user,
                              publication: other_pub_10,
                              confirmed: true }
    let!(:another_auth_10) { create :authorship,
                                    publication: other_pub_10 }
    let!(:waiver_10) { create :internal_publication_waiver, authorship: another_auth_10 }

    # Filtered out due to authorship not being confirmed
    let!(:other_pub_11) { create :publication,
                                 published_on: Date.new(2020, 7, 1) }
    let!(:o_auth_11) { create :authorship,
                              user: user,
                              publication: other_pub_11,
                              confirmed: false }

    # Filtered out due to the user having been reminded about the publication before
    let!(:other_pub_12) { create :publication,
                                 published_on: Date.new(2020, 7, 1) }
    let!(:o_auth_12) { create :authorship,
                              user: user,
                              publication: other_pub_12,
                              confirmed: true,
                              open_access_notification_sent_at: 1.month.ago }

    # Filtered out due to the publication being hidden
    let!(:other_pub_13) { create :publication,
                                 published_on: Date.new(2020, 7, 1),
                                 visible: false }
    let!(:o_auth_13) { create :authorship,
                              user: user,
                              publication: other_pub_13,
                              confirmed: true }

    # Filtered out due to the publication not being a journal article
    let!(:other_pub_14) { create :publication,
                                 published_on: Date.new(2020, 7, 1),
                                 visible: true,
                                 publication_type: 'Book' }
    let!(:o_auth_14) { create :authorship,
                              user: user,
                              publication: other_pub_14,
                              confirmed: true }

    it "returns the user's recent publications that they haven't been notified about before that don't have any associated open access information" do
      expect(user.new_potential_open_access_publications).to match_array [potential_pub_1,
                                                                          potential_pub_2]
    end
  end

  describe '#confirmed_publications' do
    let!(:u1) { create :user }
    let!(:u2) { create :user }
    let!(:p1) { create :publication }
    let!(:p2) { create :publication }
    let!(:p3) { create :publication }
    before do
      create :authorship, user: u1, publication: p2, confirmed: false
      create :authorship, user: u1, publication: p3, confirmed: true
      create :authorship, user: u2, publication: p3, confirmed: true
    end

    it "returns publications that are associated through the user through confirmed authorships" do
      expect(u1.confirmed_publications).to eq [p3]
      expect(u1.confirmed_publications.length).to eq 1
    end
  end

  describe '#admin?' do
    context "when the user's is_admin value is true" do
      before { user.is_admin = true }
      it "returns true" do
        expect(user.admin?).to eq true
      end
    end

    context "when the user's is_admin value is false" do
      before { user.is_admin = false }
      it "returns false" do
        expect(user.admin?).to eq false
      end
    end
  end

  describe '#name' do
    context "when the first, middle, and last names of the user are nil" do
      it "returns an empty string" do
        expect(user.name).to eq ''
      end
    end
    context "when the user has a first name" do
      before { user.first_name = 'first' }
      context "when the user has a middle name" do
        before { user.middle_name = 'middle' }
        context "when the user has a last name" do
          before { user.last_name = 'last' }
          it "returns the full name of the user" do
            expect(user.name).to eq 'first middle last'
          end
        end
        context "when the user has no last name" do
          before { user.last_name = '' }
          it "returns the full name of the user" do
            expect(user.name).to eq 'first middle'
          end
        end
      end
      context "when the user has no middle name" do
        before { user.middle_name = '' }
        context "when the user has a last name" do
          before { user.last_name = 'last' }
          it "returns the full name of the user" do
            expect(user.name).to eq 'first last'
          end
        end
        context "when the user has no last name" do
          before { user.last_name = '' }
          it "returns the full name of the user" do
            expect(user.name).to eq 'first'
          end
        end
      end
    end
    context "when the user has no first name" do
      before { user.first_name = '' }
      context "when the user has a middle name" do
        before { user.middle_name = 'middle' }
        context "when the user has a last name" do
          before { user.last_name = 'last' }
          it "returns the full name of the user" do
            expect(user.name).to eq 'middle last'
          end
        end
        context "when the user has no last name" do
          before { user.last_name = '' }
          it "returns the full name of the user" do
            expect(user.name).to eq 'middle'
          end
        end
      end
      context "when the user has no middle name" do
        before { user.middle_name = '' }
        context "when the user has a last name" do
          before { user.last_name = 'last' }
          it "returns the full name of the user" do
            expect(user.name).to eq 'last'
          end
        end
        context "when the user has no last name" do
          before { user.last_name = '' }
          it "returns an empty string" do
            expect(user.name).to eq ''
          end
        end
      end
    end
  end

  describe '#mark_as_updated_by_user' do
    let(:user) { User.new }
    before { allow(Time).to receive(:current).and_return Time.new(2018, 8, 23, 10, 7, 0) }

    it "sets the user's updated_by_user_at field to the current time" do
      user.mark_as_updated_by_user
      expect(user.updated_by_user_at).to eq Time.new(2018, 8, 23, 10, 7, 0)
    end
  end

  describe '#total_scopus_citations' do
    let(:user) { User.new }

    context "when the user has no publications" do
      it "returns 0" do
        expect(user.total_scopus_citations).to eq 0
      end
    end

    context "when the user only has publications that have nil citation counts" do
      let(:user) { create :user }
      let(:pub1) { create :publication, total_scopus_citations: nil }
      let(:pub2) { create :publication, total_scopus_citations: nil }

      before do
        create :authorship, user: user, publication: pub1
        create :authorship, user: user, publication: pub2
      end

      it "returns 0" do
        expect(user.total_scopus_citations).to eq 0
      end
    end

    context "when the user has publications with non-nil citation counts" do
      let(:user) { create :user }
      let(:pub1) { create :publication, total_scopus_citations: nil }
      let(:pub2) { create :publication, total_scopus_citations: 7 }
      let(:pub3) { create :publication, total_scopus_citations: 5 }

      before do
        create :authorship, user: user, publication: pub1
        create :authorship, user: user, publication: pub2
        create :authorship, user: user, publication: pub3
      end

      it "returns the sum of all of the citations for all of the user's publications" do
        expect(user.total_scopus_citations).to eq 12
      end
    end
  end

  describe '#pure_profile_url' do
    let(:user) { User.new(pure_uuid: pure_uuid) }
    let(:pure_uuid) { nil }
    context "when the user does not have a Pure UUID" do
      it "returns nil" do
        expect(user.pure_profile_url).to be_nil
      end
    end
    context "when the user's Pure UUID is blank" do
      let(:pure_uuid) { '' }

      it "returns nil" do
        expect(user.pure_profile_url).to be_nil
      end
    end
    context "when the user has a Pure UUID" do
      let(:pure_uuid) { 'pure-abc-123' }

      it "returns the URL to the user's page on the Penn State Pure website" do
        expect(user.pure_profile_url).to eq 'https://pennstate.pure.elsevier.com/en/persons/pure-abc-123'
      end
    end
  end

  describe '#office_phone_number' do
    let(:user) { User.new({ai_office_area_code: p1,
                           ai_office_phone_1: p2,
                           ai_office_phone_2: p3}) }
    let(:p1) { nil }
    let(:p2) { nil }
    let(:p3) { nil }

    context "when all of the user's office phone fields are nil" do
      it "returns nil" do
        expect(user.office_phone_number).to be_nil
      end
    end

    context "when the user's first phone field is present" do
      let(:p1) { 111 }

      context "when the user's second phone field is present" do
        let(:p2) { 222 }

        context "when the user's third phone field is present" do
          let(:p3) { 3333 }

          it "returns the full office phone number" do
            expect(user.office_phone_number).to eq '(111) 222-3333'
          end
        end
        context "when the user's third phone field is not present" do
          it "returns nil" do
            expect(user.office_phone_number).to be_nil
          end
        end
      end
      context "when the user's second phone field is not present" do
        context "when the user's third phone field is present" do
          let(:p3) { 3333 }

          it "returns nil" do
            expect(user.office_phone_number).to be_nil
          end
        end
        context "when the user's third phone field is not present" do

          it "returns nil" do
            expect(user.office_phone_number).to be_nil
          end
        end
      end
    end
    context "when the user's first phone field is not present" do
      context "when the user's second phone field is present" do
        let(:p2) { 222 }

        context "when the user's third phone field is present" do
          let(:p3) { 3333 }

          it "returns nil" do
            expect(user.office_phone_number).to be_nil
          end
        end
        context "when the user's third phone field is not present" do
          it "returns nil" do
            expect(user.office_phone_number).to be_nil
          end
        end
      end
      context "when the user's second phone field is not present" do
        context "when the user's third phone field is present" do
          let(:p3) { 3333 }

          it "returns nil" do
            expect(user.office_phone_number).to be_nil
          end
        end
        context "when the user's third phone field is not present" do
          it "returns nil" do
            expect(user.office_phone_number).to be_nil
          end
        end
      end
    end
  end

  describe '#fax_number' do
    let(:user) { User.new({ai_fax_area_code: f1,
                           ai_fax_1: f2,
                           ai_fax_2: f3}) }
    let(:f1) { nil }
    let(:f2) { nil }
    let(:f3) { nil }

    context "when all of the user's office fax fields are nil" do
      it "returns nil" do
        expect(user.fax_number).to be_nil
      end
    end

    context "when the user's first fax field is present" do
      let(:f1) { 111 }

      context "when the user's second fax field is present" do
        let(:f2) { 222 }

        context "when the user's third fax field is present" do
          let(:f3) { 3333 }

          it "returns the full office fax number" do
            expect(user.fax_number).to eq '(111) 222-3333'
          end
        end
        context "when the user's third fax field is not present" do
          it "returns nil" do
            expect(user.fax_number).to be_nil
          end
        end
      end
      context "when the user's second fax field is not present" do
        context "when the user's third fax field is present" do
          let(:f3) { 3333 }

          it "returns nil" do
            expect(user.fax_number).to be_nil
          end
        end
        context "when the user's third fax field is not present" do

          it "returns nil" do
            expect(user.fax_number).to be_nil
          end
        end
      end
    end
    context "when the user's first fax field is not present" do
      context "when the user's second fax field is present" do
        let(:f2) { 222 }

        context "when the user's third fax field is present" do
          let(:f3) { 3333 }

          it "returns nil" do
            expect(user.fax_number).to be_nil
          end
        end
        context "when the user's third fax field is not present" do
          it "returns nil" do
            expect(user.fax_number).to be_nil
          end
        end
      end
      context "when the user's second fax field is not present" do
        context "when the user's third fax field is present" do
          let(:f3) { 3333 }

          it "returns nil" do
            expect(user.fax_number).to be_nil
          end
        end
        context "when the user's third fax field is not present" do
          it "returns nil" do
            expect(user.fax_number).to be_nil
          end
        end
      end
    end
  end

  describe '#office_location' do
    let(:user) { User.new({ai_room_number: rn,
                           ai_building: b}) }
    let(:rn) { nil }
    let(:b) { nil }

    context "when the user's room number and building are nil" do
      it "returns nil" do
        expect(user.office_location).to be_nil
      end
    end

    context "when the user's room number and building are blank" do
      let(:rn) { '' }
      let(:b) { '' }

      it "returns nil" do
        expect(user.office_location).to be_nil
      end
    end

    context "when the user's room number is present" do
      let(:rn) { '123A' }

      context "when the user's building is present" do
        let(:b) { 'Test Building' }

        it "returns the full office location" do
          expect(user.office_location).to eq '123A Test Building'
        end

        context "when the building name is not title case" do
          let(:b) { 'TEST building' }

          it "returns the full office location with the building name in title case" do
            expect(user.office_location).to eq '123A Test Building'
          end
        end
      end

      context "when the user's building is blank" do
        let(:b) { '' }

        it "returns nil" do
          expect(user.office_location).to be_nil
        end
      end
    end

    context "when the user's room number is blank" do
      let(:rn) { '' }

      context "when the user's building is present" do
        let(:b) { 'Test Building' }

        it "returns nil" do
          expect(user.office_location).to be_nil
        end
      end

      context "when the user's building is blank" do
        let(:b) { '' }

        it "returns nil" do
          expect(user.office_location).to be_nil
        end
      end
    end
  end

  describe '#organization_name' do
    let!(:user) { create :user }
    let(:org) { create :organization, name: 'My Org' }
    context "when the user has no organizations" do
      it "returns nil" do
        expect(user.organization_name).to be_nil
      end
    end
    context "when the user does not have an organization from Pure" do
      before { create :user_organization_membership,
                      user: user,
                      organization: org,
                      import_source: nil }
      it "returns nil" do
        expect(user.organization_name).to be_nil
      end
    end
    context "when the user does have an organization from Pure" do
      before { create :user_organization_membership,
                      user: user,
                      organization: org,
                      import_source: 'Pure' }
      it "returns the name of the organization" do
        expect(user.organization_name).to eq 'My Org'
      end
    end
  end

  describe '#primary_organization_membership' do
    let!(:user) { create :user }
    let(:org1) { create :organization, name: 'My Org 1' }
    let(:org2) { create :organization, name: 'My Org 2' }
    let(:org3) { create :organization, name: 'My Org 3' }

    context "when the user has no organizations" do
      it "returns nil" do
        expect(user.primary_organization_membership).to be_nil
      end
    end
    context "when the user does not have an organization from Pure" do
      before { create :user_organization_membership,
                      user: user,
                      organization: org1,
                      import_source: nil }
      it "returns nil" do
        expect(user.primary_organization_membership).to be_nil
      end
    end
    context "when the user has multiple organization memberships" do
      let!(:membership1) { create :user_organization_membership,
                           user: user,
                           organization: org1,
                           import_source: nil }
      let!(:membership2) { create :user_organization_membership,
                           user: user,
                           organization: org2,
                           import_source: 'Pure' }
      let!(:membership3) { create :user_organization_membership,
                           user: user,
                           organization: org3,
                           import_source: 'Pure' }
      it "returns the first record of membership in an organization from Pure" do
        expect(user.primary_organization_membership).to eq membership2
      end
    end
  end

  describe '#orcid' do
    let(:user) { User.new(orcid_identifier: orcid_id) }
    let(:orcid_id) { nil }
    context "when the user has no orcid_identifier" do
      it "returns nil" do
        expect(user.orcid).to be_nil
      end
    end
    context "when the user's orcid_identifier is blank" do
      let(:orcid_id) { "" }
      it "returns nil" do
        expect(user.orcid).to be_nil
      end
    end
    context "when the user has an orcid_identifier URL" do
      let(:orcid_id) { "https://orcid.org/0000-0123-4567-890X" }
      it "returns just the ORCiD ID part of the URL" do
        expect(user.orcid).to eq "0000-0123-4567-890X"
      end
    end
  end

  describe '#clear_orcid_access_token' do
    let(:user) { create :user, orcid_access_token: token }
    context "when the user has an orcid_access_token value" do
      let(:token) { 'a_token' }

      it "removes the value" do
        user.clear_orcid_access_token
        expect(user.reload.orcid_access_token).to be_nil
      end
    end
  end

  describe '#record_open_access_notification' do
    let(:user) { create :user }
    let(:now) { Time.new(2020, 6, 12, 15, 21, 0) }
    before { allow(Time).to receive(:current).and_return(now) }

    it "saves the current time in the open access notification timestamp field" do
      user.record_open_access_notification
      expect(user.reload.open_access_notification_sent_at).to eq now
    end
  end
end
