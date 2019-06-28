require 'component/component_spec_helper'

describe ProfilesController, type: :controller do

  describe '#edit' do
    context "when not authenticated" do
      it "redirects to the sign in page" do
        get :edit

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
