# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the api_tokens table', type: :model do
  subject { APIToken.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:token).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:app_name).of_type(:string) }
  it { is_expected.to have_db_column(:admin_email).of_type(:string) }
  it { is_expected.to have_db_column(:write_access).of_type(:boolean).with_options(default: false) }
  it { is_expected.to have_db_column(:total_requests).of_type(:integer).with_options(default: 0) }
  it { is_expected.to have_db_column(:last_used_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:token).unique(true) }
end

describe APIToken, type: :model do
  it_behaves_like 'an application record'

  it { is_expected.to have_many(:organization_api_permissions).inverse_of(:api_token) }
  it { is_expected.to have_many(:organizations).through(:organization_api_permissions) }

  describe 'creating a new token' do
    let(:new_token) { described_class.new }

    it 'sets a value for the token that is 64 characters long' do
      new_token.save!
      expect(new_token.token.length).to eq 96
    end
  end

  describe 'deleting a token' do
    let(:token) { create(:api_token) }
    let!(:permission) { create(:organization_api_permission, api_token: token) }

    it 'also deletes any associated organization API permissions' do
      token.destroy
      expect { permission.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe '#increment_request_count' do
    let(:token) { create(:api_token,
                         total_requests: 2,
                         last_used_at: Time.zone.local(2000, 1, 1, 8, 0, 0)) }

    before do
      allow(Time).to receive(:current).and_return(Time.zone.local(2017, 11, 3, 9, 45, 0))
    end

    it 'increases the saved number of total requests for the token by 1' do
      token.increment_request_count
      expect(token.reload.total_requests).to eq 3
    end

    it 'updates the last_used_at timestamp on the token' do
      token.increment_request_count
      expect(token.reload.last_used_at).to eq Time.zone.local(2017, 11, 3, 9, 45, 0)
    end
  end

  describe '#organization_count' do
    let!(:token) { create(:api_token) }
    let!(:org1) { create(:organization) }
    let!(:org2) { create(:organization) }

    before do
      create(:organization_api_permission, organization: org1, api_token: token)
      create(:organization_api_permission, organization: org2, api_token: token)
    end

    it 'returns the number of organization with which the API token is associated' do
      expect(token.organization_count).to eq 2
    end
  end

  describe 'token permissions' do
    let!(:token) { create(:api_token) }
    let!(:org1) { create(:organization) }
    let!(:user1) { create(:user) }
    let!(:user_org_membership1) { create(:user_organization_membership,
                                         user: user1,
                                         organization: org1,
                                         started_on: 1.year.ago,
                                         ended_on: nil) }
    let!(:pub1) { create(:publication, published_on: 6.months.ago) }
    let!(:authorship1) { create(:authorship, publication: pub1, user: user1) }
    let!(:org2) { create(:organization, parent_id: org1.id) }
    let!(:user2) { create(:user) }
    let!(:user_org_membership2) { create(:user_organization_membership,
                                         user: user2,
                                         organization: org2,
                                         started_on: 1.year.ago,
                                         ended_on: nil) }
    let!(:pub2_1) { create(:publication, published_on: 6.months.ago) }
    let!(:authorship2_1) { create(:authorship, publication: pub2_1, user: user2) }
    # pub2_2 excluded from #all_publications since it was not published during the user's time within the org
    let!(:pub2_2) { create(:publication, published_on: 2.years.ago) }
    let!(:authorship2_2) { create(:authorship, publication: pub2_2, user: user2) }
    let!(:org3) { create(:organization, parent_id: org2.id) }
    let!(:user3_1) { create(:user) }
    let!(:user_org_membership3_1) { create(:user_organization_membership,
                                           user: user3_1,
                                           organization: org3,
                                           started_on: 1.year.ago,
                                           ended_on: nil) }
    let!(:pub3_1) { create(:publication, published_on: 6.months.ago) }
    let!(:authorship3_1) { create(:authorship, publication: pub3_1, user: user3_1) }
    # user3_2 excluded from #all_current_users because the user is not actively in the org
    let!(:user3_2) { create(:user) }
    let!(:user_org_membership3_2) { create(:user_organization_membership,
                                           user: user3_2,
                                           organization: org3,
                                           started_on: 1.year.ago,
                                           ended_on: Date.yesterday) }
    # pub3_2 included in #all_publications since it was published when the user was a part of the org
    let!(:pub3_2) { create(:publication, published_on: 6.months.ago) }
    let!(:authorship3_2) { create(:authorship, publication: pub3_2, user: user3_2) }
    # org4, its users, and publications excluded from everthing since it is not
    # linked to the token nor is it a descendant of a linked org
    let!(:org4) { create(:organization) }
    let!(:user4) { create(:user) }
    let!(:user_org_membership4) { create(:user_organization_membership,
                                         user: user4,
                                         organization: org4,
                                         started_on: 1.year.ago,
                                         ended_on: nil) }
    let!(:pub4) { create(:publication, published_on: 6.months.ago) }
    let!(:authorship4) { create(:authorship, publication: pub4, user: user4) }

    before do
      create(:organization_api_permission, organization: org1, api_token: token)
    end

    describe '#all_publications' do
      it "returns publications that were published during their users'
          memberships in associated organizations and their descendants" do
        expect(token.all_publications).to match_array [pub1, pub2_1, pub3_1, pub3_2]
      end
    end

    describe '#all_current_users' do
      it 'returns users that are currently members of associated organizations and their descendants' do
        expect(token.all_current_users).to match_array [user1, user2, user3_1]
      end
    end

    describe '#all_organizations' do
      it 'returns organizations that are associated organizations and their descendants' do
        expect(token.all_organizations).to match_array [org1, org2, org3]
      end
    end
  end
end
