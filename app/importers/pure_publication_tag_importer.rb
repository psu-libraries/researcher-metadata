# frozen_string_literal: true

class PurePublicationTagImporter < PureImporter
  def call
    pbar = ProgressBarTTY.create(title: 'Importing Pure publication tags', total: total_pages)

    1.upto(total_pages) do |i|
      offset = (i - 1) * page_size
      pubs = get_records(type: record_type, page_size: page_size, offset: offset)

      pubs['items'].each do |publication|
        pub_uuid = publication['uuid']
        pub_import = PublicationImport.find_by(source_identifier: pub_uuid)
        next unless pub_import

        pub = pub_import.publication
        # In Pure, a fingerprint is a ranked collection of concepts.
        # Concepts belong to different categories. Sometimes the same concept
        # term appears multiple times in a fingerprint if it belongs to multiple
        # categories.
        tags = {} # Where we'll collect concept terms and ranks.
        # We don't care about the high-level categories, just the
        # terms.
        # Pure outputs fingerprints as XML within the publication JSON
        fingerprint_xml = publication['renderings'].find { |r| r['format'] == 'fingerprint' }['html']
        # We need to parse these xml fingerprints
        f = Nokogiri::XML(fingerprint_xml)
        f.xpath('fingerprint').xpath('rankedConcept').each do |rc|
          # Collect concept terms and ranks
          term_as_provided = rc.xpath('term').text
          # NOTE: Terms returned don't maintain consistent titleization.
          # Example: "Protein Folding" and "Protein folding"
          term = term_as_provided.present? ? term_as_provided.downcase.titleize : nil
          rank_as_text = rc.xpath('rank').text
          rank = rank_as_text.present? ? rank_as_text.to_f : 0
          # If the term already appeared in a different category in this
          # fingerprint, then we add the ranks together
          tags[term] = if tags[term].present?
                         tags[term] + rank
                       else
                         rank
                       end
        end

        tags.each do |term, rank|
          tag = Tag.find_or_create_by(name: term)
          pub.taggings.create_with(
            rank: rank
          ).find_or_create_by(tag: tag)
        end
      rescue StandardError => e
        log_error(e, {
                    publication_import_id: pub_import&.id,
                    publication_id: pub&.id,
                    fingerprint: fingerprint_xml,
                    publication: publication
                  })
      end
      pbar.increment
    rescue StandardError => e
      log_error(e, {})
    end
    pbar.finish
  rescue StandardError => e
    log_error(e, {})
  end

  def page_size
    500
  end

  def record_type
    'research-outputs'
  end

  private

    def get_records(type:, page_size:, offset:)
      JSON.parse(HTTParty.post("#{base_url}/#{record_type}",
                               body: %{{"navigationLink": false, "size": #{page_size}, "offset": #{offset}, "renderings": ["fingerprint"]}},
                               headers: { 'api-key' => pure_api_key,
                                          'Content-Type' => 'application/json',
                                          'Accept' => 'application/json' }).to_s)
    end
end
