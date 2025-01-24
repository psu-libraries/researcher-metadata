# frozen_string_literal: true

require 'component/component_spec_helper'

describe PSULawSchoolOAICreator do
  let(:creator) { described_class.new('Tester, Sue') }

  describe '#last_name' do
    it 'returns the first word of the given text' do
      expect(creator.last_name).to eq 'Tester'
    end
  end

  describe '#first_name' do
    it 'returns the second word of the given text' do
      expect(creator.first_name).to eq 'Sue'
    end
  end

  describe '#user_match' do
    context "when the given text doesn't match the name of any users" do
      it 'returns nil' do
        expect(creator.user_match).to be_nil
      end
    end

    context 'when the given text matches the name of a user that is not in one of the law schools' do
      let!(:user) { create(:user, first_name: 'Sue', last_name: 'Tester') }
      let!(:org) { create(:organization, pure_external_identifier: 'OTHER') }

      before do
        create(:user_organization_membership, user: user, organization: org)
      end

      it 'returns nil' do
        expect(creator.user_match).to be_nil
      end
    end

    context 'when the given text matches the name of a user in the Dickinson law school' do
      let!(:user) { create(:user, first_name: 'Sue', last_name: 'Tester') }
      let!(:org) { create(:organization, pure_external_identifier: 'CAMPUS-DN') }

      before do
        create(:user_organization_membership, user: user, organization: org)
      end

      it 'returns the matching user' do
        expect(creator.user_match).to eq user
      end
    end

    context 'when the given text matches the name of a user in the PSU law school' do
      let!(:user) { create(:user, first_name: 'Sue', last_name: 'Tester') }
      let!(:org) { create(:organization, pure_external_identifier: 'COLLEGE-PL') }

      before do
        create(:user_organization_membership, user: user, organization: org)
      end

      it 'returns the matching user' do
        expect(creator.user_match).to eq user
      end
    end

    context 'when the given text matches the name of two users in the PSU law school' do
      let!(:user1) { create(:user, first_name: 'Sue', last_name: 'Tester') }
      let!(:user2) { create(:user, first_name: 'Sue', last_name: 'Tester') }
      let!(:org) { create(:organization, pure_external_identifier: 'COLLEGE-PL') }

      before do
        create(:user_organization_membership, user: user1, organization: org)
        create(:user_organization_membership, user: user2, organization: org)
      end

      it 'returns nil' do
        expect(creator.user_match).to be_nil
      end
    end
  end

  describe '#ambiguous_user_matches' do
    context "when the given text doesn't match the name of any users" do
      it 'returns an empty array' do
        expect(creator.ambiguous_user_matches).to eq []
      end
    end

    context 'when the given text matches the name of a user that is not in one of the law schools' do
      let!(:user) { create(:user, first_name: 'Sue', last_name: 'Tester') }
      let!(:org) { create(:organization, pure_external_identifier: 'OTHER') }

      before do
        create(:user_organization_membership, user: user, organization: org)
      end

      it 'returns an empty array' do
        expect(creator.ambiguous_user_matches).to eq []
      end
    end

    context 'when the given text matches the name of a user in the Dickinson law school' do
      let!(:user) { create(:user, first_name: 'Sue', last_name: 'Tester') }
      let!(:org) { create(:organization, pure_external_identifier: 'CAMPUS-DN') }

      before do
        create(:user_organization_membership, user: user, organization: org)
      end

      it 'returns an empty array' do
        expect(creator.ambiguous_user_matches).to eq []
      end
    end

    context 'when the given text matches the name of a user in the PSU law school' do
      let!(:user) { create(:user, first_name: 'Sue', last_name: 'Tester') }
      let!(:org) { create(:organization, pure_external_identifier: 'COLLEGE-PL') }

      before do
        create(:user_organization_membership, user: user, organization: org)
      end

      it 'returns an empty array' do
        expect(creator.ambiguous_user_matches).to eq []
      end
    end

    context 'when the given text matches the name of two users in the PSU law school' do
      let!(:user1) { create(:user, first_name: 'Sue', last_name: 'Tester') }
      let!(:user2) { create(:user, first_name: 'Sue', last_name: 'Tester') }
      let!(:org) { create(:organization, pure_external_identifier: 'COLLEGE-PL') }

      before do
        create(:user_organization_membership, user: user1, organization: org)
        create(:user_organization_membership, user: user2, organization: org)
      end

      it 'returns the matching users' do
        expect(creator.ambiguous_user_matches).to match_array [user1, user2]
      end
    end
  end
end
