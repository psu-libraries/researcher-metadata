class StatisticsSnapshot < ApplicationRecord

  def self.record
    create(total_publication_count: Publication.count,
           open_access_publication_count: Publication.open_access.count)
  end

  def percent_open_access
    ((open_access_publication_count.to_f / total_publication_count) * 100).round 1
  end

  rails_admin do
    list do
      field(:created_at)
      field(:total_publication_count)
      field(:open_access_publication_count)
      field(:percent_open_access)
    end

    show do
      field(:created_at)
      field(:total_publication_count)
      field(:open_access_publication_count)
      field(:percent_open_access)
    end
  end
end
