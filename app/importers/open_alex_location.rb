# frozen_string_literal: true

class OpenAlexLocation
  def initialize(parsed_location, work)
    @parsed_location = parsed_location
    @work = work
  end

  def id
    parsed_location['id']
  end

  def name
    source['display_name'] if source
  end

  def host_type
    source['type'] if source
  end

  def best_oa?
    id == work.best_oa_location_id
  end

  def license
    parsed_location['license']
  end

  def landing_page_url
    parsed_location['landing_page_url']
  end

  def pdf_url
    parsed_location['pdf_url']
  end

  def version
    parsed_location['version']
  end

  def published?
    parsed_location['is_published']
  end

  private

    attr_reader :parsed_location, :work

    def source
      parsed_location['source']
    end
end
