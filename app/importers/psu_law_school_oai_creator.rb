# frozen_string_literal: true

class PSULawSchoolOAICreator < OAICreator
  private

    def law_school_organization_ids
      @ids ||= Organization.where(pure_external_identifier: ['COLLEGE-PL', 'CAMPUS-DN']).pluck(:id).uniq
    end

    def user_scope
      User.joins(:user_organization_memberships)
        .where(user_organization_memberships: { organization_id: law_school_organization_ids })
    end
end
