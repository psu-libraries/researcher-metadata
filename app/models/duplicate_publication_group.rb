class DuplicatePublicationGroup < ApplicationRecord
  has_many :publications, inverse_of: :duplicate_group

  def self.group_duplicates
    pbar = ProgressBar.create(title: 'Grouping duplicate publications',
                              total: Publication.count) unless Rails.env.test?

    Publication.find_each do |p|
      duplicates = Publication.where(%{similarity(title, ?) >= 0.6 AND (EXTRACT(YEAR FROM published_on) = ? OR published_on IS NULL) AND (doi = ? OR doi IS NULL)},
                                     p.title,
                                     p.published_on.try(:year),
                                     p.doi)

      group_publications(duplicates)

      pbar.increment unless Rails.env.test?
    end
    pbar.finish unless Rails.env.test?

    nil
  end

  def self.group_publications(publications)
    if publications.many?
      existing_groups = publications.select { |p| p.duplicate_group.present? }.map { |p| p.duplicate_group }
      group_to_remain = existing_groups.first
      groups_to_delete = existing_groups - [group_to_remain]
      pubs_to_regroup = groups_to_delete.map { |g| g.publications }.flatten

      ActiveRecord::Base.transaction do
        if group_to_remain
          publications.each do |p|
            p.update_attributes!(duplicate_group: group_to_remain) unless p.duplicate_group.present?
          end
          pubs_to_regroup.each do |p|
            p.update_attributes!(duplicate_group: group_to_remain)
          end
          groups_to_delete.each do |g|
            g.destroy
          end
        else
          create!(publications: publications)
        end
      end
    end
  end

  rails_admin do
    configure :publications do
      pretty_value do
        bindings[:view].render :partial => "rails_admin/partials/duplicate_publication_groups/publications.html.erb", :locals => { :publications => value }
      end
    end

    list do
      field(:id)
      field(:first_publication_title) { label 'Title of first duplicate' }
      field(:publication_count) { label 'Number of duplicates' }
    end

    show do
      field(:id)
      field(:publications)
    end
  end

  def publication_count
    publications.count
  end

  def first_publication_title
    publications.first.try(:title)
  end
end
