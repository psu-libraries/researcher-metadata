# frozen_string_literal: true

class PsuIdentityUserService
  class IdentityServiceError < StandardError; end

  class << self
    def find_or_initialize_user(webaccess_id:)
      user = User.find_by(webaccess_id: webaccess_id) ||
        initialize_user_from_psu_identity(webaccess_id)

      if user.persisted?
        identity = query_psu_identity(webaccess_id)
        return user if identity.blank?

        user.update attrs(identity)
      end
      user.save
      user
    end

    private

      def initialize_user_from_psu_identity(webaccess_id)
        identity = query_psu_identity(webaccess_id)
        return nil if identity.blank?

        User.new(attrs(identity).merge!(webaccess_id: webaccess_id))
      end

      def query_psu_identity(webaccess_id)
        PsuIdentity::SearchService::Client.new.userid(webaccess_id)
      rescue URI::InvalidURIError
        nil
      rescue StandardError
        raise IdentityServiceError
      end

      def attrs(identity)
        {
          first_name: (identity.preferred_given_name.presence || identity.given_name),
          last_name: (identity.preferred_family_name.presence || identity.family_name),
          psu_identity: identity,
          psu_identity_updated_at: Time.zone.now
        }
      end
  end
end
