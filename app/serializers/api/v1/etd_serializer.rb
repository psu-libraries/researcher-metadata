module API::V1
  class ETDSerializer
    include FastJsonapi::ObjectSerializer
    attributes :title, :year, :author_last_name, :author_first_name, :author_middle_name
  end
end
