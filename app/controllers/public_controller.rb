class PublicController < ApplicationController
  before_action :authenticate_user!

  def home
    @env = Rails.env
  end
end
