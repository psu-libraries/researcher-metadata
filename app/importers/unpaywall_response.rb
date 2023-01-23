# frozen_string_literal: true

class UnpaywallResponse
  attr_reader :json

  def initialize(json)
    @json = json
  end

  def doi
    json['doi']
  end
  
  def doi_url
    json['doi_url']
  end

  def title
    json['title']
  end
  
  def genre
    json['genre']
  end

  def is_paratext
    json['is_paratext']
  end

  def published_date
    json['published_date']
  end
  
  def year
    json['year']
  end

  def journal_name
    json['journal_name']
  end

  def journal_issns
    json['journal_issns']
  end

  def journal_issn_l
    json['journal_issn_l']
  end
  
  def journal_is_oa
    json['journal_is_oa']
  end

  def journal_is_in_doaj
    json['journal_is_in_doaj']
  end

  def publisher
    json['publisher']
  end

  def is_oa
    json['is_oa']
  end

  def oa_status
    json['oa_status']
  end

  def has_repository_copy
    json['has_repository_copy']
  end

  def best_oa_location
    json['best_oa_location']
  end
  
  def first_oa_location
    json['first_oa_location']
  end

  def oa_locations
    #if there are any locations present
      #json['oa_locations'].each do |unpaywall_location_data|
        #assign data to new open access location object
        #put object in array
        #return array
      #end
    #end
    json['oa_locations']
  end
  
  def oa_locations_embargoed
    json['oa_locations_embargoed']
  end

  def updated
    json['updated']
  end
  
  def data_standard
    json['data_standard']
  end
  
  def z_authors
    json['z_authors']
  end

    #possibly move to response class?
  def update_open_access_location(open_access_location)
    open_access_location.assign_attributes(
      landing_page_url: json['url_for_landing_page'],
      pdf_url: json['url_for_pdf'],
      host_type: json['host_type'],
      is_best: json['is_best'],
      license: json['license'],
      oa_date: json['oa_date'],
      source_updated_at: json['updated'],
      version: json['version']
    )
    open_access_location.save!
  end
end