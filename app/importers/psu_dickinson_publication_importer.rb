# frozen_string_literal: true

class PSUDickinsonPublicationImporter < OAIImporter
  private

    def record_type
      PSULawSchoolOAIRepoRecord
    end

    def import_source
      'Dickinson Law IDEAS Repo'
    end

    # TODO this is a temporary method so we can refactor the sources used in
    # OpenAccessLocation and PublicationImport separately. Once botha are refactored
    # to use the Source object, then we should remove this method and only
    # use #import_source
    def location_source
      Source::DICKINSON_IDEAS
    end

    def repo_url
      'https://ideas.dickinsonlaw.psu.edu/do/oai'
    end

    def set
      'publication:fac-works'
    end
end
