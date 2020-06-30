FactoryBot.define do
  factory :non_duplicate_publication_group_membership do
    publication { create :publication }
    non_duplicate_group { create :non_duplicate_publication_group }
  end
end
