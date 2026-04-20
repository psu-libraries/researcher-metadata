# frozen_string_literal: true

require 'requests/requests_spec_helper'

describe 'GET /delayed_job' do # rubocop:disable RSpec/DescribeClass
  context 'when not logged in' do
    it 'returns 404 (route is hidden from unauthenticated users)' do
      get '/delayed_job'
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when logged in as a non-admin user' do
    let(:user) { create(:user, is_admin: false) }

    before do
      sign_in_as(user)
      get '/users/auth/azure_oauth/callback'
    end

    it 'returns 404 (route is hidden from non-admins)' do
      get '/delayed_job'
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when logged in as an admin user' do
    let(:user) { create(:user, is_admin: true) }

    before do
      sign_in_as(user)
      get '/users/auth/azure_oauth/callback'
    end

    it 'returns 200' do
      get '/delayed_job'
      follow_redirect! # Sinatra redirects /delayed_job → /delayed_job/ (trailing slash)
      expect(response).to have_http_status(:ok)
    end
  end
end
