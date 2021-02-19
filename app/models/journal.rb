class Journal < ApplicationRecord
  belongs_to :publisher, inverse_of: :journals, optional: true
  has_many :publications, inverse_of: :journal

  scope :ordered_by_publication_count, -> { unscope(:order).left_outer_joins(:publications).group('journals.id').order(Arel.sql('COUNT(publications.id) DESC')) }
  scope :ordered_by_title, -> { order(:title) }

  def publication_count
    publications.count
  end

  def psu_publication_count
    publications.published_during_membership.count
  end

  rails_admin do
    list do
      scopes [:ordered_by_title, :ordered_by_publication_count]
      field(:id)
      field(:title)
      field(:publication_count)
      field(:psu_publication_count) { label 'PSU publication count' }
    end

    show do
      field(:title)
      field(:pure_uuid)
      field(:publisher)
      field(:publication_count)
      field(:psu_publication_count) { label 'PSU publication count' }
      field(:publications)
    end

    export do
      configure :publication_count do
        show
      end
    end
  end
end
