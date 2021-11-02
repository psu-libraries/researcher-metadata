# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe UserController, type: :controller do
  controller do
    def index
      current_user
      render plain: 'OK'
    end
  end

  let(:perform_request) { get :index }

  it_behaves_like 'an unauthenticated controller'

  # @note To avoid having to dig into Devise to mimic its current_user behavior, we're just testing that our builder
  # class gets called. The actual user that get returned is test within that builder's spec test, as well as integration
  # tests where the user is pretending to be someone else. Here, all we're concerned about is did the controller call
  # the builder to set the current user.
  context 'when setting the current user' do
    before do
      allow(CurrentUserBuilder).to receive(:call)
      allow(request.env['warden']).to receive(:authenticate!)
    end

    it 'sets the current user to the user' do
      perform_request
      expect(CurrentUserBuilder).to have_received(:call)
      expect(request.env['warden']).to have_received(:authenticate!)
    end
  end
end
