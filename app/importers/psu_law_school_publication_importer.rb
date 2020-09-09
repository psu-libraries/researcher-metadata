class PSULawSchoolPublicationImporter < OAIImporter
  def creator_type
    PSULawSchoolOAICreator
  end

  private

  def import_source
    "Penn State Law eLibrary Repo"
  end

  def repo_url
    'https://elibrary.law.psu.edu/do/oai'
  end
end
