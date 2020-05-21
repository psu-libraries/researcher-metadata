require 'component/component_spec_helper'

describe OrcidEmploymentsController, type: :controller do

  describe '#create' do
    context "when the user is authenticated" do
      let!(:user) { create :user }
      let(:employment) { double 'ORCID employment', save!: nil, location: "the_location" }
      before do
        allow(user).to receive(:primary_organization_membership).and_return(membership)
        allow(OrcidEmployment).to receive(:new).with(membership).and_return(employment)
        authenticate_as(user)
        post :create
      end
      context "when the user has a primary organization membership" do
        let(:membership) { double 'user organization membership',
                                  started_on: Date.new(1999, 12, 31),
                                  orcid_resource_identifier: id,
                                  update_attributes!: nil }
        context "when the employment has already been added to the user's ORCID record" do
          let(:id) { "abc123" }

          it "sets a flash message" do
            expect(flash[:notice]).to eq I18n.t('profile.orcid_employments.create.already_added')
          end
  
          it "redirects back to the profile bio page" do
            expect(response).to redirect_to profile_bio_path
          end
        end
  
        context "when the employment has not been added to the user's ORCID record" do
          let(:id) { nil }

          it "saves the membership info as an employment in the user's ORCID record" do
            expect(employment).to have_received :save!
          end

          it "updates the membership with the identifier of the employment that was created in ORCID" do
            expect(membership).to have_received(:update_attributes!).with(orcid_resource_identifier: 'the_location')
          end

          it "sets a flash message" do
            expect(flash[:notice]).to eq I18n.t('profile.orcid_employments.create.success')
          end
  
          it "redirects back to the profile bio page" do
            expect(response).to redirect_to profile_bio_path
          end

          context "when the ORCID access token is not valid" do
            before do
              allow(employment).to receive(:save!).and_raise(OrcidEmployment::InvalidToken)
              allow(user).to receive(:clear_orcid_access_token)
              post :create
            end

            it "clears the user's ORCID access token" do
              expect(user).to have_received :clear_orcid_access_token
            end

            it "sets a flash message" do
              expect(flash[:alert]).to eq I18n.t('profile.orcid_employments.create.account_not_linked')
            end
          end

          context "when there is an error saving the employment to ORCID" do
            before do
              allow(employment).to receive(:save!).and_raise(OrcidEmployment::FailedRequest)
              post :create
            end

            it "sets a flash message" do
              expect(flash[:alert]).to eq I18n.t('profile.orcid_employments.create.error')
            end
          end
        end
      end
    end

    context "when the user is not authenticated" do
      it "redirects to the sign in page" do
        post :create
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
