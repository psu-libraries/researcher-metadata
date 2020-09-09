class PSUDickinsonPublicationImporter < OAIImporter
  def creator_type
    PSULawSchoolOAICreator
  end

  private

  def import_source
    "Dickinson Law IDEAS Repo"
  end

  def repo_url
    'https://ideas.dickinsonlaw.psu.edu/do/oai'
  end
end
