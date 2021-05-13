require 'component/component_spec_helper'

describe CustomAdmin::DuplicatePublicationGroupsController, type: :controller do
  let!(:group) { create :duplicate_publication_group }
  describe '#delete' do
    context "when authenticated as an admin" do
      before do
        user = User.new(is_admin: true)
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context "when the group has one publication" do
        let!(:pub1) { create :publication, duplicate_publication_group_id: group.id }

        it "removes the publication from the group" do
          delete :delete, params: { id: group.id }

          expect(pub1.reload.duplicate_publication_group_id).to be_nil
        end

        it "deletes the group" do
          delete :delete, params: { id: group.id }

          expect { group.reload }.to raise_error ActiveRecord::RecordNotFound
        end

        it "sets a flash success message" do
          delete :delete, params: { id: group.id }

          expect(flash[:success]).to eq I18n.t('admin.duplicate_publication_groups.delete.success')
        end

        it "redirects to the duplicate publication group list page" do
          delete :delete, params: { id: group.id }

          expect(response).to redirect_to index_path(model_name: :duplicate_publication_group)
        end
      end

      context "when the group has two publications" do
        let!(:pub1) { create :publication, duplicate_group: group }
        let!(:pub2) { create :publication, duplicate_group: group }

        it "doesn't remove the publications from the group" do
          delete :delete, params: { id: group.id }

          expect(group.publications).to match_array [pub1, pub2]
        end

        it "doesn't delete the group" do
          delete :delete, params: { id: group.id }

          expect { group.reload }.not_to raise_error
        end

        it "sets a flash error message" do
          delete :delete, params: { id: group.id }

          expect(flash[:error]).to eq I18n.t('admin.duplicate_publication_groups.delete.multiple_publications_error')
        end

        it "redirects to the duplicate publication group list page" do
          delete :delete, params: { id: group.id }

          expect(response).to redirect_to index_path(model_name: :duplicate_publication_group)
        end
      end
    end

    context "when authenticated as a non-admin user" do
      before do
        user = User.new(is_admin: false)
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
      end
      it "redirects back to the home page with an error message" do
        delete :delete, params: { id: group.id }

        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq I18n.t('admin.authorization.not_authorized')
      end
    end

    context "when not authenticated" do
      it "redirects to the admin home page" do
        delete :delete, params: { id: group.id }

        expect(response).to redirect_to root_path
      end

      it "shows an error message" do
        delete :delete, params: { id: group.id }

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end
  end
end