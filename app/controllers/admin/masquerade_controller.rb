# frozen_string_literal: true

module Admin
  class MasqueradeController < RailsAdmin::ApplicationController
    include ::MasqueradingBehaviors
  end
end
