class PSULawSchoolOAIRepoRecord < OAIRepoRecord

  private

  def journal_article?
    [
      "Journal Articles",
      "Penn State International Law Review",
      "Penn State Journal of Law & International Affairs",
      "Arbitration Law Review",
      "Faculty Scholarly Works",
      "Dickinson Law Review"
    ].include?(source)
  end

  def creator_type
    PSULawSchoolOAICreator
  end
end
