# frozen_string_literal: true

class OpenAccessLocationMergePolicy
  def initialize(publications)
    @publications = publications
  end

  def open_access_locations_to_keep
    publications.map(&:open_access_locations).flatten.uniq { |oal| [oal.source, oal.url] }
  end

  private

    attr_reader :publications
end
