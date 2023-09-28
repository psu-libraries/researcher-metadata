# frozen_string_literal: true

class OrganizationProfilesController < ProfileManagementController
  skip_before_action :authenticate!

  def show
    @organization = Organization.find(params[:organization_id])
    @publications = @organization.all_publications.order(published_on: :desc).page params[:page]
  end
end
