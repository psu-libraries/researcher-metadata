# frozen_string_literal: true

module OpenAlexDatasetImporter
  SOURCE = 'Open Alex'

  def self.call
    OpenAlexDatasets.find_in_batches do |ds|
      if ds.importable?
        existing_import = PublicationImport.find_by(source: SOURCE, source_identifier: ds.open_alex_identifier)

        unless existing_import
          ActiveRecord::Base.transaction do
            p = Publication.new
            p.doi = ds.doi
            p.title = ds.title
            p.publication_type = ds.type
            p.status = Publication::PUBLISHED_STATUS
            p.published_on = ds.publication_date
            p.open_access_status = ds.oa_status
            p.publisher_name = ds.publisher
            p.save!

            pi = PublicationImport.new
            pi.source = SOURCE
            pi.source_identifier = ds.open_alex_identifier
            pi.source_updated_at = ds.updated_at
            pi.publication = p
            pi.save!
          end
        end
      end
    end
  end
end
