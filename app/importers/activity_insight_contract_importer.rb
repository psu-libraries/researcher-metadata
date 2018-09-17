class ActivityInsightContractImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    if row[:ospkey].present? && row[:status] == 'Awarded'
      u = User.find_by(webaccess_id: row[:username])

      ci = ContractImport.find_by(activity_insight_id: row[:id]) ||
           ContractImport.new(activity_insight_id: row[:id],
                              contract: Contract.find_by(ospkey: row[:ospkey]) || 
                              Contract.create!(contract_attrs(row)))

      c = ci.contract

      if ci.persisted?
        c.update_attributes!(contract_attrs(row))
        return nil
      else
        u&.contracts&.push(c)
        u&.save!
      end

      ci
    end
  end

  private

  def bulk_import(objects)
    ContractImport.import(objects)
  end

  def contract_attrs(row)
    {
      title: row[:title],
      contract_type: row[:type],
      sponsor: row[:sponorg],
      status: row[:status],
      amount: row[:amount],
      ospkey: row[:ospkey],
      award_start_on: row[:award_start],
      award_end_on: row[:award_end],
    }
  end

end
