# frozen_string_literal: true

# One brittle test to verify our interaction with the real PSU identity web service
require 'component/component_spec_helper'

describe UserProfile do
  subject(:profile) { described_class.new(user) }

  describe '::new' do
    context 'when the user has data from the identity management service' do
      let(:user) {
        create(
          :user,
          :with_psu_identity,
          webaccess_id: 'dmc186',
          first_name: 'Test',
          last_name: 'User'
        )
      }

      it 'does NOT update their identity' do
        described_class.new(user)
        u = user.reload
        expect(u.first_name).to eq 'Test'
        expect(u.middle_name).to be_nil
        expect(u.last_name).to eq 'User'
        expect(u.psu_identity.data).to eq({ 'affiliation' => ['FACULTY'], 'familyName' => 'User', 'givenName' => 'Test', 'userid' => 'dmc186' })
      end
    end

    context 'when the user has not updated their identity data' do
      let(:user) {
        create(
          :user,
          webaccess_id: 'dmc186',
          first_name: 'Test',
          last_name: 'User'
        )
      }

      it 'updates their identity' do
        described_class.new(user)
        u = user.reload
        expect(u.first_name).to eq 'Daniel'
        expect(u.middle_name).to eq 'M'
        expect(u.last_name).to eq 'Coughlin'
        expect(u.psu_identity.data['givenName']).to eq 'Daniel'
        expect(u.psu_identity.data['middleName']).to eq 'M'
        expect(u.psu_identity.data['familyName']).to eq 'Coughlin'
        expect(u.psu_identity.data['affiliation']).to eq ['FACULTY', 'MEMBER']
        expect(u.psu_identity.data['userid']).to eq 'dmc186'
        expect(u.psu_identity_updated_at).not_to be_nil
      end
    end
  end
end
