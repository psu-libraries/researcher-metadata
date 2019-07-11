require 'component/component_spec_helper'

describe ProfilesController, type: :controller do

  describe '#edit_publications' do
    context "when not authenticated" do
      it "redirects to the sign in page" do
        get :edit_publications

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
