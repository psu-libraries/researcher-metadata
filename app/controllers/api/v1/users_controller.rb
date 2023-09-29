# frozen_string_literal: true

module API::V1
  class UsersController < APIController
    include ActionController::MimeResponds

    def presentations
      user = api_token.all_current_users.find_by(webaccess_id: params[:webaccess_id])
      if user
        @presentations = API::V1::UserQuery.new(user).presentations(params)
        respond_to do |format|
          format.html
          format.json { render json: API::V1::PresentationSerializer.new(@presentations) }
        end
      else
        render json: { message: 'User not found', code: 404 }, status: :not_found
      end
    end

    def grants
      user = api_token.all_current_users.find_by(webaccess_id: params[:webaccess_id])
      if user
        @grants = API::V1::UserQuery.new(user).grants
        respond_to do |format|
          format.html
          format.json { render json: API::V1::GrantSerializer.new(@grants) }
        end
      else
        render json: { message: 'User not found', code: 404 }, status: :not_found
      end
    end

    def news_feed_items
      user = api_token.all_current_users.find_by(webaccess_id: params[:webaccess_id])
      if user
        @news_feed_items = API::V1::UserQuery.new(user).news_feed_items(params)
        respond_to do |format|
          format.html
          format.json { render json: API::V1::NewsFeedItemSerializer.new(@news_feed_items) }
        end
      else
        render json: { message: 'User not found', code: 404 }, status: :not_found
      end
    end

    def performances
      user = api_token.all_current_users.find_by(webaccess_id: params[:webaccess_id])
      if user
        @performances = API::V1::UserQuery.new(user).performances(params)
        respond_to do |format|
          format.html
          format.json { render json: API::V1::PerformanceSerializer.new(@performances) }
        end
      else
        render json: { message: 'User not found', code: 404 }, status: :not_found
      end
    end

    def etds
      @user = api_token.all_current_users.find_by(webaccess_id: params[:webaccess_id])
      if @user
        @etds = API::V1::UserQuery.new(@user).etds(params)
        respond_to do |format|
          format.html
          format.json { render json: API::V1::ETDSerializer.new(@etds) }
        end
      else
        render json: { message: 'User not found', code: 404 }, status: :not_found
      end
    end

    def publications
      user = api_token.all_current_users.find_by(webaccess_id: params[:webaccess_id])
      if user
        @pubs = API::V1::UserQuery.new(user).publications(params)
        respond_to do |format|
          format.html
          format.json { render json: API::V1::PublicationSerializer.new(@pubs) }
        end
      else
        render json: { message: 'User not found', code: 404 }, status: :not_found
      end
    end

    def organization_memberships
      user = api_token.all_current_users.find_by(webaccess_id: params[:webaccess_id])
      if user
        @memberships = user.user_organization_memberships
        respond_to do |format|
          format.html
          format.json { render json: API::V1::OrganizationMembershipSerializer.new(@memberships) }
        end
      else
        render json: { message: 'User not found', code: 404 }, status: :not_found
      end
    end

    def profile
      headers['Access-Control-Allow-Origin'] = '*' if Rails.env.development?

      user = User.find_by(webaccess_id: params[:webaccess_id])
      if user
        @profile = UserProfile.new(user)
        respond_to do |format|
          format.html
          format.json { render json: API::V1::UserProfileSerializer.new(@profile) }
        end
      else
        render json: { message: 'User not found', code: 404 }, status: :not_found
      end
    end

    def users_publications
      data = {}
      api_token.all_current_users.includes(:publications).where(webaccess_id: params[:_json]).each do |user|
        pubs = API::V1::UserQuery.new(user).publications(params)
        data[user.webaccess_id] = API::V1::PublicationSerializer.new(pubs).serializable_hash
      end
      render json: data
    end
  end
end
