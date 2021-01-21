class StatisticsSnapshot < ApplicationRecord

  rails_admin do
    list do
      field(:created_at)
      field(:total_publication_count)
      field(:open_access_publication_count)
    end

    show do
      field(:created_at)
      field(:total_publication_count)
      field(:open_access_publication_count)
    end
  end
end
