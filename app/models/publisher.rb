class Publisher < ApplicationRecord
  has_many :journals, inverse_of: :publisher
  has_many :publications, through: :journals

  scope :ordered_by_publication_count, -> { unscope(:order).left_outer_joins(:publications).group('publishers.id').order(Arel.sql('COUNT(publications.id) DESC')) }
  scope :ordered_by_psu_publication_count, -> { 
    unscope(:order).
      left_outer_joins(publications: [:user_organization_memberships]).
      group('publishers.id').
      where('publications.visible IS TRUE').
      where('publications.published_on >= user_organization_memberships.started_on AND (published_on <= user_organization_memberships.ended_on OR user_organization_memberships.ended_on IS NULL)').
      order(Arel.sql('COUNT(DISTINCT publications.id) DESC'))
  }
  scope :ordered_by_name, -> { order(:name) }

  def publication_count
    publications.count
  end

  def psu_publication_count
    publications.published_during_membership.count
  end

  rails_admin do
    list do
      scopes [:ordered_by_name, :ordered_by_publication_count, :ordered_by_psu_publication_count]
      field(:id)
      field(:name)
      field(:publication_count)
      field(:psu_publication_count) { label 'PSU publication count' }
    end

    show do
      field(:name)
      field(:pure_uuid)
      field(:journals)
      field(:publication_count)
      field(:psu_publication_count) { label 'PSU publication count' }
      field(:publications)
    end

    export do
      configure(:publication_count) { show }
      configure(:psu_publication_count) { show }
    end
  end
end
