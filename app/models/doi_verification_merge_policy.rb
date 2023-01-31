# frozen_string_literal: true

class DoiVerificationMergePolicy
  def initialize(main_pub, publications)
    @publications = publications
    @main_pub = main_pub
  end

  def merge!
    unverified = nil
    verified = nil
    unverified_doi = nil

    publications.each do |pub|
      if pub.doi_verified == true
        verified = true
        main_pub.doi = pub.doi
        main_pub.doi_verified = true
      end

      if pub.doi_verified == false
        unverified = true
        unverified_doi = pub.doi
      end
    end

    if unverified && !verified
      main_pub.doi = unverified_doi
      main_pub.doi_verified = false
    end

    main_pub.save!
  end

  private

    attr_accessor :publications, :main_pub
end
