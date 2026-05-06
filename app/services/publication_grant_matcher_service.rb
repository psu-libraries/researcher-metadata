# frozen_string_literal: true

class PublicationGrantMatcherService
  def match_from_pure(funding_data, pub)
    funding_data&.each do |fund|
      fund['fundingNumbers']&.each do |fund_num|
        grant = Grant.find_by(agency_name: fund['fundingOrganizationAcronym'], identifier: fund_num)
        if grant && !ResearchFund.find_by(publication: pub, grant: grant)
          research_fund = ResearchFund.new
          research_fund.publication = pub
          research_fund.grant = grant
          research_fund.import_source = 'Pure'
          research_fund.save!
        end
      end
    end
  end
end
