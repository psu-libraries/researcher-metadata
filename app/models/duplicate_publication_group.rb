class DuplicatePublicationGroup < ApplicationRecord
  has_many :publications

  def self.group_duplicates
    Publication.all.each do |p|
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
          duplicates.update_all(duplicate_publication_group_id: existing_group.id)
        else
          new_group = create!
          duplicates.update_all(duplicate_publication_group_id: new_group.id)
        end
      end
    end

    nil
  end
end
