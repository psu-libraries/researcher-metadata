# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe OrcidWorksController, type: :controller do
  it { is_expected.to be_a(UserController) }

  describe '#create' do
    let(:perform_request) { post :create }

    it_behaves_like 'an unauthenticated controller'

    context 'when the user is authenticated' do
      let!(:user) { create :user }
      let(:work) { double 'ORCID work', save!: nil, location: 'the_location' }
      let(:now) { Time.new(2021, 1, 13, 11, 26, 0) }

      before do
        allow(OrcidWork).to receive(:new).with(authorship).and_return(work)
        allow(user).to receive_message_chain(:confirmed_authorships, :find).and_return(authorship)
        allow(Time).to receive(:current).and_return(now)
        allow(request.env['warden']).to receive(:authenticate!).and_return(user)
        allow(controller).to receive(:current_user).and_return(user)
        post :create
      end

      context 'when the user has an authorship' do
        let(:authorship) { double 'authorship',
                                  orcid_resource_identifier: id,
                                  update!: nil }

        context "when the work has already been added to the user's ORCID record" do
          let(:id) { 'abc123' }

          it 'sets a flash message' do
            expect(flash[:notice]).to eq I18n.t('profile.orcid_works.create.already_added')
          end

          it 'redirects back to the profile bio page' do
            expect(response).to redirect_to edit_profile_publications_path
          end
        end

        context "when the authorship has not been added to the user's ORCID record" do
          let(:id) { nil }

          it "saves the authorship info as a work in the user's ORCID record" do
            expect(work).to have_received :save!
          end

          it 'updates the authorship with the identifier of the work that was created in ORCID' do
            expect(authorship).to have_received(:update!).with(orcid_resource_identifier: 'the_location',
                                                               updated_by_owner_at: now)
          end

          it 'sets a flash message' do
            expect(flash[:notice]).to eq I18n.t('profile.orcid_works.create.success')
          end

          it 'redirects back to the profile bio page' do
            expect(response).to redirect_to edit_profile_publications_path
          end

          context 'when the ORCID access token is not valid' do
            before do
              allow(work).to receive(:save!).and_raise(OrcidWork::InvalidToken)
              allow(user).to receive(:clear_orcid_access_token)
              post :create
            end

            it "clears the user's ORCID access token" do
              expect(user).to have_received :clear_orcid_access_token
            end

            it 'sets a flash message' do
              expect(flash[:alert]).to eq I18n.t('profile.orcid_works.create.account_not_linked')
            end
          end

          context 'when there is an error saving the work to ORCID' do
            before do
              allow(work).to receive(:save!).and_raise(OrcidWork::FailedRequest)
              post :create
            end

            it 'sets a flash message' do
              expect(flash[:alert]).to eq I18n.t('profile.orcid_works.create.error')
            end
          end
        end
      end

      context 'when the user does not have an authorship' do
        let(:authorship) { nil }

        it "does not try to save a work in the user's ORCID record" do
          expect(work).not_to have_received :save!
        end

        it 'redirects back to the profile bio page' do
          expect(response).to redirect_to edit_profile_publications_path
        end
      end
    end
  end
end
