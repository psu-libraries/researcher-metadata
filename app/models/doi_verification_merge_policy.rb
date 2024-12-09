# frozen_string_literal: true

class DOIVerificationMergePolicy
  class UnmergablePublications < RuntimeError; end

  def initialize(main_pub, publications)
    @publications = publications
    @main_pub = main_pub
  end

  def merge!
    raise UnmergablePublications if given_unmergable_pubs?

    return if main_pub.has_verified_doi?

    pubs_to_merge.each do |p|
      if p.has_verified_doi? || (main_pub.doi.blank? && p.doi.present?)
        main_pub.doi = p.doi
        main_pub.doi_verified = p.doi_verified
      end
    end

    if main_pub.doi.blank?
      if pubs_to_merge.find { |p| p.doi.blank? && p.doi_verified }
        main_pub.doi_verified = true
      elsif pubs_to_merge.find { |p| p.doi.blank? && p.doi_verified == false } && !main_pub.doi_verified
        main_pub.doi_verified = false
      end
    end

    main_pub.save!
  end

  private

    attr_accessor :publications, :main_pub

    def pubs_to_merge
      publications - [main_pub]
    end

    def all_verified_dois
      all_verified_dois = []
      all_verified_dois.push(main_pub.doi) if main_pub.has_verified_doi?
      pubs_to_merge.each do |p|
        all_verified_dois.push(p.doi) if p.has_verified_doi?
      end
      all_verified_dois
    end

    def given_unmergable_pubs?
      all_verified_dois.uniq.count > 1
    end
end
