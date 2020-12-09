class PSUDickinsonPublicationImporter < OAIImporter

  private

  def record_type
    PSULawSchoolOAIRepoRecord
  end

  def import_source
    "Dickinson Law IDEAS Repo"
  end

  def repo_url
    'https://ideas.dickinsonlaw.psu.edu/do/oai'
  end

  def set
    'publication:fac-works'
  end
end
