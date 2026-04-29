# frozen_string_literal: true

class NIHProjectInvestigator
  def initialize(investigator_data)
    @investigator_data = investigator_data
  end

  def first_name
    investigator_data['first_name']
  end

  def middle_name
    investigator_data['middle_name']
  end

  def last_name
    investigator_data['last_name']
  end

  private

    attr_reader :investigator_data
end
