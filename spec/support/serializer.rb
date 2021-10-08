# frozen_string_literal: true

def serialized_data_attributes(object)
  serialize(object)[:data][:attributes]
end

def serialize(object)
  described_class.new(object).serializable_hash
end
