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

    if pub_to_merge_with_verified_doi
      main_pub.doi = pub_to_merge_with_verified_doi.doi
      main_pub.doi_verified = pub_to_merge_with_verified_doi.doi_verified
    elsif main_pub.doi.blank?
      if pub_to_merge_with_unverified_doi_from_pure
        main_pub.doi = pub_to_merge_with_unverified_doi_from_pure.doi
        main_pub.doi_verified = pub_to_merge_with_unverified_doi_from_pure.doi_verified
      elsif pub_to_merge_with_unverified_doi
        main_pub.doi = pub_to_merge_with_unverified_doi.doi
        main_pub.doi_verified = pub_to_merge_with_unverified_doi.doi_verified
      elsif pub_to_merge_with_verified_blank_doi
        main_pub.doi_verified = true
      elsif pubs_to_merge_with_unverified_blank_doi && !main_pub.doi_verified
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

    def pub_to_merge_with_verified_doi
      @pub_to_merge_with_verified_doi ||= pubs_to_merge.find(&:has_verified_doi?)
    end

    def pub_to_merge_with_unverified_doi_from_pure
      @pub_to_merge_with_unverified_doi_from_pure ||= pubs_to_merge.find do |p|
        p.doi.present? && !p.doi_verified && p.has_pure_import?
      end
    end

    def pub_to_merge_with_unverified_doi
      @pub_to_merge_with_unverified_doi ||= pubs_to_merge.find do |p|
        p.doi.present? && !p.doi_verified
      end
    end

    def pub_to_merge_with_verified_blank_doi
      pubs_to_merge.find { |p| p.doi.blank? && p.doi_verified }
    end

    def pubs_to_merge_with_unverified_blank_doi
      pubs_to_merge.find { |p| p.doi.blank? && p.doi_verified == false }
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
      all_verified_dois.uniq(&:downcase).many?
    end
end
