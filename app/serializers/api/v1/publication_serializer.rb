module API::V1
  class PublicationSerializer
    include FastJsonapi::ObjectSerializer
    attributes :title, :secondary_title, :journal_title, :publication_type, :status,
               :volume, :issue, :edition, :page_range, :authors_et_al

    attribute :published_on do |object|
      object.published_on.try(:iso8601)
    end

    attribute :contributors do |object|
      object.contributors.map do |c|
        {first_name: c.first_name,
         middle_name: c.middle_name,
         last_name: c.last_name}
      end
    end
  end
end
