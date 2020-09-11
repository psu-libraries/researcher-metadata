class PSULawSchoolPublicationImporter < OAIImporter

  private

  def record_type
    PSULawSchoolOAIRepoRecord
  end
  
  def import_source
    "Penn State Law eLibrary Repo"
  end

  def repo_url
    'https://elibrary.law.psu.edu/do/oai'
  end
end
