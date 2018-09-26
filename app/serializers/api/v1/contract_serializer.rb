module API::V1
  class ContractSerializer
    include FastJsonapi::ObjectSerializer
    attributes :title, :contract_type, :sponsor, :status, :amount, :ospkey

    attribute :award_start_on do |object|
      object.award_start_on.try(:iso8601)
    end

    attribute :award_end_on do |object|
      object.award_end_on.try(:iso8601)
    end
  end
end
