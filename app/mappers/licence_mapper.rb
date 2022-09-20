# frozen_string_literal: true

class LicenceMapper
  def self.map(string)
    return nil if string.nil?

    case string.downcase
    when 'cc-by', 'cc-by 3.0', 'cc-by 4.0'
      ScholarsphereWorkDeposit.rights[0]
    when 'cc-by-nc'
      ScholarsphereWorkDeposit.rights[2]
    when 'cc-by-nc-nd'
      ScholarsphereWorkDeposit.rights[4]
    when 'cc-by-nc-sa'
      ScholarsphereWorkDeposit.rights[5]
    when 'cc0'
      ScholarsphereWorkDeposit.rights[7]
    else
      ScholarsphereWorkDeposit.rights[8]
    end
  end
end
