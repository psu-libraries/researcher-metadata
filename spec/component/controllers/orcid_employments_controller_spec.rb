# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe OrcidEmploymentsController, type: :controller do
  it { is_expected.to be_a(UserController) }

  describe '#create' do
    let(:perform_request) { post :create, params: { membership_id: '2' } }

    it_behaves_like 'an unauthenticated controller'

    context 'when the user is authenticated' do
      let!(:user) { create :user }
      let(:employment) { double 'ORCID employment', save!: nil, location: 'the_location' }
      let(:membership_collection) { double 'membership collection' }

      before do
        allow(user).to receive(:user_organization_memberships).and_return(membership_collection)
        allow(membership_collection).to receive(:find).with('2').and_return(membership)
        allow(OrcidEmployment).to receive(:new).with(membership).and_return(employment)
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
        post :create, params: { membership_id: '2' }
      end

      context 'when the user has a primary organization membership' do
        let(:membership) { double 'user organization membership',
                                  started_on: Date.new(1999, 12, 31),
                                  orcid_resource_identifier: id,
                                  update!: nil }

        context "when the employment has already been added to the user's ORCID record" do
          let(:id) { 'abc123' }

          it 'sets a flash message' do
            expect(flash[:notice]).to eq I18n.t('profile.orcid_employments.create.already_added')
          end

          it 'redirects back to the profile bio page' do
            expect(response).to redirect_to profile_bio_path
          end
        end

        context "when the employment has not been added to the user's ORCID record" do
          let(:id) { nil }

          it "saves the membership info as an employment in the user's ORCID record" do
            expect(employment).to have_received :save!
          end

          it 'updates the membership with the identifier of the employment that was created in ORCID' do
            expect(membership).to have_received(:update!).with(orcid_resource_identifier: 'the_location')
          end

          it 'sets a flash message' do
            expect(flash[:notice]).to eq I18n.t('profile.orcid_employments.create.success')
          end

          it 'redirects back to the profile bio page' do
            expect(response).to redirect_to profile_bio_path
          end

          context 'when the ORCID access token is not valid' do
            before do
              allow(employment).to receive(:save!).and_raise(OrcidEmployment::InvalidToken)
              allow(user).to receive(:clear_orcid_access_token)
              post :create, params: { membership_id: '2' }
            end

            it "clears the user's ORCID access token" do
              expect(user).to have_received :clear_orcid_access_token
            end

            it 'sets a flash message' do
              expect(flash[:alert]).to eq I18n.t('profile.orcid_employments.create.account_not_linked')
            end
          end

          context 'when there is an error saving the employment to ORCID' do
            before do
              allow(employment).to receive(:save!).and_raise(OrcidEmployment::FailedRequest)
              post :create, params: { membership_id: '2' }
            end

            it 'sets a flash message' do
              expect(flash[:alert]).to eq I18n.t('profile.orcid_employments.create.error')
            end
          end
        end
      end

      context 'when the user does not have a primary organization membership' do
        let(:membership) { nil }

        it "does not try to save an employment in the user's ORCID record" do
          expect(employment).not_to have_received :save!
        end

        it 'redirects back to the profile bio page' do
          expect(response).to redirect_to profile_bio_path
        end
      end
    end
  end
end
