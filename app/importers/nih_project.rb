# frozen_string_literal: true

class NIHProject
  def initialize(project_data)
    @project_data = project_data
  end

  def title
    project_data['project_title']
  end

  def start_date
    parse_date(project_data['budget_start'])
  end

  def end_date
    parse_date(project_data['budget_end'])
  end

  def abstract
    project_data['abstract_text']
  end

  def amount_in_dollars
    project_data['award_amount']
  end

  def identifier
    project_data['project_num']
  end

  def agency_name
    project_data['agency_code']
  end

  def principal_investigators
    project_data['principal_investigators'].map do |pi_data|
      NIHProjectInvestigator.new(pi_data)
    end
  end

  def publications
    @publications ||= NIHAPIClient.new.publications_by_project(core_project_number).map do |pub_data|
      NIHProjectPublication.new(pub_data)
    end
  end

  private

    attr_reader :project_data

    def parse_date(date)
      Date.iso8601(date)
    end

    def core_project_number
      project_data['core_project_num']
    end
end
