require 'component/component_spec_helper'

describe Devise::Strategies::HttpHeaderAuthenticatable do
  let(:strategy) { Devise::Strategies::HttpHeaderAuthenticatable.new(headers) }
  let(:headers) {{ 'REMOTE_USER' => psu_id }}

  def authenticate!
    strategy.authenticate!
  end

  context "when given a WebAccess ID that corresponds to an existing user" do
    let(:psu_id) { 'esd122' }
    let!(:user) { create :user, webaccess_id: psu_id }

    it "succeeds" do
      authenticate!
      expect(strategy.successful?).to be_truthy
    end
  end

  context "when given a WebAccess ID that does not correspond to an existing user" do
    let(:psu_id) { 'bad_id' }
    it "fails" do
      authenticate!
      expect(strategy.successful?).to be_falsey
    end
  end
end
