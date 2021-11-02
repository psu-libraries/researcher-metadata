# frozen_string_literal: true

shared_examples_for 'an unauthenticated controller' do
  before do
    raise 'perform_request must be set with `let(:perform_request)`' unless defined? perform_request
  end

  context 'when the user is not authenticated' do
    before { perform_request }

    it 'redirects to the home page' do
      expect(response).to redirect_to root_path
    end

    it 'sets a flash error message' do
      expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
    end
  end
end
