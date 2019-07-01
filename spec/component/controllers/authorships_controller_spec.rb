require 'component/component_spec_helper'

describe AuthorshipsController, type: :controller do

  describe '#update' do
    context "when not authenticated" do
      it "redirects to the sign in page" do
        put :update, params: {id: 1}

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
