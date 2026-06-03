# frozen_string_literal: true

class OpenAlexWork
  def initialize(parsed_work)
    @parsed_work = parsed_work
  end

  def doi
    DOISanitizer.new(parsed_work['doi']).url
  end

  def title
    parsed_work['title']
  end

  def type
    parsed_work['type']
  end

  def publication_date
    Date.parse(parsed_work['publication_date'])
  end

  def open_alex_identifier
    parsed_work['id']
  end

  def updated_at
    Time.parse(parsed_work['updated_date'])
  end

  def has_published_location?
    !!locations.find(&:published?)
  end

  def oa_status
    parsed_work['open_access']['oa_status']
  end

  def publisher
    primary_location.name
  end

  def locations
    parsed_work['locations'].map do |l|
      OpenAlexLocation.new(l, self)
    end
  end

  def primary_location_id
    primary_location.id
  end

  def best_oa_location_id
    OpenAlexLocation.new(parsed_work['best_oa_location'], self).id
  end

  def all_authors
    parsed_work['authorships'].map.with_index do |a, i|
      OpenAlexAuthor.new(a, i)
    end
  end

  def psu_authors
    all_authors.select(&:psu_affiliated?)
  end

  private

    attr_reader :parsed_work

    def primary_location
      OpenAlexLocation.new(parsed_work['primary_location'], self)
    end
end
