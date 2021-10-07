require 'component/component_spec_helper'

describe ProfilesController, type: :controller do
  describe '#edit_publications' do
    context 'when not authenticated' do
      it 'redirects to the home page' do
        get :edit_publications

        expect(response).to redirect_to root_path
      end

      it 'sets a flash error message' do
        get :edit_publications

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end
  end

  describe '#edit_presentations' do
    context 'when not authenticated' do
      it 'redirects to the home page' do
        get :edit_presentations

        expect(response).to redirect_to root_path
      end

      it 'sets a flash error message' do
        get :edit_presentations

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end
  end

  describe '#edit_performances' do
    context 'when not authenticated' do
      it 'redirects to the home page' do
        get :edit_performances

        expect(response).to redirect_to root_path
      end

      it 'sets a flash error message' do
        get :edit_performances

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end
  end

  describe '#edit_other_publications' do
    context 'when not authenticated' do
      it 'redirects to the home page' do
        get :edit_other_publications

        expect(response).to redirect_to root_path
      end

      it 'sets a flash error message' do
        get :edit_other_publications

        expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
      end
    end
  end
end
