# frozen_string_literal: true

class PSUDickinsonPublicationImporter < OAIImporter
  private

    def record_type
      PSULawSchoolOAIRepoRecord
    end

    def import_source
      'Insight at Dickinson Law'
    end

    # TODO this is a temporary method so we can refactor the sources used in
    # OpenAccessLocation and PublicationImport separately. Once botha are refactored
    # to use the Source object, then we should remove this method and only
    # use #import_source
    def location_source
      Source::INSIGHT_DICKINSON
    end

    def repo_url
      'https://insight.dickinsonlaw.psu.edu/do/oai'
    end

    def set
      'publication:fac-works'
    end
end
