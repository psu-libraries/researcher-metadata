# frozen_string_literal: true

require 'component/component_spec_helper'

describe AuthorshipClaimService do
  let(:service) { described_class.new(user, pub, 3) }
  let(:user) { double 'user', claim_publication: auth }
  let(:pub) { double 'publication' }
  let(:email) { spy 'notification email' }
  let(:auth) { double 'authorship' }

  before { allow(AdminNotificationsMailer).to receive(:authorship_claim).with(auth).and_return email }

  describe '#create' do
    it 'claims the given publication for the given user' do
      service.create
      expect(user).to have_received(:claim_publication).with(pub, 3)
    end

    it 'sends a notification email RMD admins' do
      service.create
      expect(email).to have_received(:deliver_now)
    end
  end
end
