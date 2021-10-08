# frozen_string_literal: true

class PSULawSchoolOAIRepoRecord < OAIRepoRecord
  private

    def creator_type
      PSULawSchoolOAICreator
    end
end
