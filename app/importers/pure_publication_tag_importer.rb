class PurePublicationTagImporter
  def initialize(filename:)
    @filename = filename
    @errors = []
  end

  def call
    File.open(filename, 'r') do |file|
      json = MultiJson.load(file)
      pbar = ProgressBar.create(title: 'Importing Pure publication tags', total: json['items'].count) unless Rails.env.test?
      json['items'].each do |publication|
        pbar.increment unless Rails.env.test?
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
        fingerprint_xml = publication['renderings'][0]['value']
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
          if tags[term].present?
            tags[term] = tags[term] + rank
          else
            tags[term] = rank
          end
        end

        tags.each do |term, rank|
          tag = Tag.find_or_create_by(name: term)
          pub.taggings.create_with(
            rank: rank
          ).find_or_create_by(tag: tag)
        end
      end
      pbar.finish unless Rails.env.test?
    end
    nil
  end

  private

  attr_reader :filename
end
