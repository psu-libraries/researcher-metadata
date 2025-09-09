# frozen_string_literal: true

class PSUDickinsonOAIRepoRecord < OAIRepoRecord
  private

    def creator_type
      PSUDickinsonOAICreator
    end
end
