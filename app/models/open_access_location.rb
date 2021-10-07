class OpenAccessLocation < ApplicationRecord
  def self.sources
    ["User", "ScholarSphere", "Open Access Button", "Unpaywall"]
  end

  belongs_to :publication, inverse_of: :open_access_locations

  validates :publication, :source, :url, presence: true
  validates :source, inclusion: {in: sources}
end
