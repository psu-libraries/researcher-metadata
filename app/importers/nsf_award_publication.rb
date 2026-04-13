# frozen_string_literal: true

class NSFAwardPublication
  def initialize(award_pub_data)
    @award_pub_data = award_pub_data
  end

  def title
    award_pub_data['artTitl']
  end

  def year
    award_pub_data['jrnlYr']
  end

  def doi
    DOISanitizer.new(award_pub_data['dgtlObjId']).url
  end

  private

    attr_reader :award_pub_data
end
