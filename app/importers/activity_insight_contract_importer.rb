class ActivityInsightContractImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    if row[:ospkey].present? && status(row) == 'Awarded'
      u = User.find_by(webaccess_id: row[:username].downcase)

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
      status: status(row),
      amount: row[:amount],
      ospkey: row[:ospkey],
      award_start_on: row[:award_start],
      award_end_on: row[:award_end],
    }
  end

  def status(row)
    extract_value(row: row, header_key: :status, header_count: 2)
  end

  def extract_value(row:, header_key:, header_count:)
    value = nil
    header_count.times do |i|
      if i == 0
        value = row[header_key] if row[header_key].present? && row[header_key].to_s.downcase != 'other'
      else
        key = header_key.to_s + (i+1).to_s
        value = row[key.to_sym] if row[key.to_sym].present? && row[key.to_sym].to_s.downcase != 'other'
      end
    end
    value
  end

end
