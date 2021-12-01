# frozen_string_literal: true

class PsuIdentityUserService
  class IdentityServiceError < StandardError; end

  class << self
    def find_or_initialize_user(webaccess_id:)
      User.find_by(webaccess_id: webaccess_id) ||
        initialize_user_from_psu_identity(webaccess_id)
    end

    private

      def initialize_user_from_psu_identity(webaccess_id)
        identity = query_psu_identity(webaccess_id)
        return nil if identity.blank?

        User.new(
          webaccess_id: webaccess_id,
          first_name: (identity.preferred_given_name.presence || identity.given_name),
          last_name: (identity.preferred_family_name.presence || identity.family_name),
          psu_identity: identity,
          psu_identity_updated_at: Time.zone.now
        )
      end

      def query_psu_identity(webaccess_id)
        PsuIdentity::SearchService::Client.new.userid(webaccess_id)
      rescue URI::InvalidURIError
        nil
      rescue StandardError
        raise IdentityServiceError
      end
  end
end
