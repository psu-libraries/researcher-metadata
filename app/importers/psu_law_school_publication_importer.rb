# frozen_string_literal: true

class PSULawSchoolPublicationImporter < OAIImporter
  private

    def record_type
      PSULawSchoolOAIRepoRecord
    end

    def import_source
      'Penn State Law eLibrary Repo'
    end

    # TODO this is a temporary method so we can refactor the sources used in
    # OpenAccessLocation and PublicationImport separately. Once botha are refactored
    # to use the Source object, then we should remove this method and only
    # use #import_source
    def location_source
      Source::PSU_LAW_ELIBRARY
    end

    def repo_url
      'https://elibrary.law.psu.edu/do/oai'
    end

    def set
      'publication:fac_works'
    end
end
