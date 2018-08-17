class DuplicatePublicationGroup < ApplicationRecord
  has_many :publications, inverse_of: :duplicate_group

  def self.group_duplicates
    pbar = ProgressBar.create(title: 'Grouping duplicate publications',
                              total: Publication.count) unless Rails.env.test?

    Publication.find_each do |p|
      duplicates = Publication.where("volume = ? AND issue = ? AND title ILIKE ? and (journal_title ILIKE ? OR journal_title ILIKE ? OR publisher ILIKE ? OR publisher ILIKE ?) AND EXTRACT(YEAR FROM published_on) = ?",
                                     p.volume,
                                     p.issue,
                                     "%#{p.title}%",
                                     p.journal_title,
                                     p.publisher,
                                     p.journal_title,
                                     p.publisher,
                                     p.published_on.try(:year))

      if duplicates.many?
        existing_group = duplicates.detect { |p| p.duplicate_group.present? }.try(:duplicate_group)

        if existing_group
          duplicates.each do |dp|
            dp.update_attributes!(duplicate_group: existing_group) unless dp.duplicate_group.present?
          end
        else
          new_group = create!
          duplicates.update_all(duplicate_publication_group_id: new_group.id)
        end
      end
      pbar.increment unless Rails.env.test?
    end
    pbar.finish unless Rails.env.test?

    nil
  end

  rails_admin do
    configure :publications do
      pretty_value do
        bindings[:view].render :partial => "rails_admin/partials/duplicate_publication_groups/publications.html.erb", :locals => { :publications => value }
      end
    end

    list do
      field :id
    end

    show do
      field :id
      field :publications
    end
  end
end
