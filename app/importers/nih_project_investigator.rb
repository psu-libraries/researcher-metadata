# frozen_string_literal: true

class NIHProjectInvestigator
  def initialize(investigator_data)
    @investigator_data = investigator_data
  end

  def first_name
    investigator_data['first_name'].downcase
  end

  def middle_initial
    mn = investigator_data['middle_name'].presence
    mn.downcase[0] if mn
  end

  def last_name
    investigator_data['last_name'].downcase
  end

  private

    attr_reader :investigator_data
end
