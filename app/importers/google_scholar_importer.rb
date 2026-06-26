# frozen_string_literal: true

class GoogleScholarImporter
  def initialize(profile_importer: GoogleScholarProfileImporter.new,
                 publication_citation_importer: GoogleScholarPublicationCitationImporter.new)
    @profile_importer = profile_importer
    @publication_citation_importer = publication_citation_importer
  end

  def call
    profile_importer.call
    publication_citation_importer.call
  end

  private

    attr_reader :profile_importer, :publication_citation_importer
end
