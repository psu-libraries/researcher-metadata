# frozen_string_literal: true

class NIHAPIClient
  REQUEST_RECORD_LIMIT = 500

  def projects_pages_count
    total_count = projects_count
    pages = total_count / REQUEST_RECORD_LIMIT
    if (total_count % REQUEST_RECORD_LIMIT).zero?
      pages
    else
      pages + 1
    end
  end

  def projects_count
    projects = NIHProjects.new(request_projects(offset: 0, limit: 1))
    projects.total_count
  end

  def projects(page)
    offset = (page - 1) * REQUEST_RECORD_LIMIT
    request_projects(offset: offset, limit: REQUEST_RECORD_LIMIT)
  end

  def publications_by_project(project_number)
    nih_pubs = request_resource(
      resource: 'publications',
      criteria: { core_project_nums: [project_number] },
      offset: 0,
      limit: REQUEST_RECORD_LIMIT
    )['results']

    nih_pubs.filter_map do |p|
      HTTParty.get("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=#{p['pmid']}").body
    rescue StandardError => e
      log_error(
        e,
        {
          project_number: project_number,
          pmid: p['pmid']
        }
      )
      nil
    end
  end

  private

    def request_resource(resource:, criteria:, offset:, limit:)
      response = HTTParty.post(
        "https://api.reporter.nih.gov/v2/#{resource}/search",
        body: JSON.generate(
          {
            criteria: criteria,
            offset: offset,
            limit: limit
          }
        ),
        headers: {
          'Content-Type' => 'application/json',
          'accept' => 'application/json'
        }
      )

      JSON.parse(response.body)
    end

    def request_projects(offset:, limit:)
      request_resource(
        resource: 'projects',
        criteria: { org_names: ['The Pennsylvania State University'] },
        offset: offset,
        limit: limit
      )
    end

    def log_error(error, metadata)
      ImporterErrorLog.log_error(
        importer_class: self.class,
        error: error,
        metadata: metadata
      )
    end
end
