# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/controllers/shared_examples_for_an_unauthenticated_controller'

describe ProfilesController, type: :controller do
  describe '#edit_publications' do
    let(:perform_request) { get :edit_publications }

    it_behaves_like 'an unauthenticated controller'
  end

  describe '#edit_presentations' do
    let(:perform_request) { get :edit_presentations }

    it_behaves_like 'an unauthenticated controller'
  end

  describe '#edit_performances' do
    let(:perform_request) { get :edit_performances }

    it_behaves_like 'an unauthenticated controller'
  end

  describe '#edit_other_publications' do
    let(:perform_request) { get :edit_other_publications }

    it_behaves_like 'an unauthenticated controller'
  end
end
