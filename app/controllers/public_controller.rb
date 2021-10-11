# frozen_string_literal: true

class PublicController < ApplicationController
  def home
    @env = Rails.env
  end

  def resources; end
end
