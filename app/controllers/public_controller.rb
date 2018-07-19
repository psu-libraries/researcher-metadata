class PublicController < ApplicationController
  def home
    @env = Rails.env
  end
end
