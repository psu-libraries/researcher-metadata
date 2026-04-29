# frozen_string_literal: true

class NIHProjects
  def initialize(projects_data)
    @projects_data = projects_data
  end

  def self.find_in_batches(&)
    c = NIHAPIClient.new
    (1..c.projects_pages_count).each do |page|
      sleep 1 unless Rails.env.test?
      projects = new(c.projects(page))
      projects.each(&)
    end
  end

  def each(&)
    projects_data['results'].each do |result|
      yield NIHProject.new(result)
    end
  end

  def total_count
    projects_data['meta']['total']
  end

  private

    attr_reader :projects_data
end
