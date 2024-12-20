# frozen_string_literal: true

class DuplicatePublicationGroup < ApplicationRecord
  has_many :publications, inverse_of: :duplicate_group

  def self.group_duplicates
    pbar = Utilities::ProgressBarTTY.create(title: 'Grouping duplicate publications',
                                            total: Publication.count)

    Publication.find_each do |p|
      already_grouped = p.duplicate_group.present?
      group_duplicates_of(p)

      group = p.reload.duplicate_group
      if !already_grouped && group
        p.update!(visible: false)
      end
      pbar.increment
    end
    pbar.finish

    nil
  end

  def self.group_duplicates_of(publication)
    duplicates = if publication.imports.count == 1 && publication.imports.find { |i| i.source == 'Activity Insight' }
                   Publication.where(%{(similarity(CONCAT(title, secondary_title), ?) >= 0.6 AND (? BETWEEN EXTRACT(YEAR FROM published_on)-2 AND EXTRACT(YEAR FROM published_on)+2 OR published_on IS NULL)) OR (doi ILIKE ? AND doi != '')},
                                     "#{publication.title}#{publication.secondary_title}",
                                     publication.published_on.try(:year),
                                     publication.doi)
                     .where.not(id: publication.non_duplicate_groups.map { |g| g.memberships.map(&:publication_id) }.flatten).or(Publication.where(id: publication.id))
                 else
                   Publication.where(%{(similarity(CONCAT(title, secondary_title), ?) >= 0.6 AND (? BETWEEN EXTRACT(YEAR FROM published_on)-2 AND EXTRACT(YEAR FROM published_on)+2 OR published_on IS NULL) AND (doi ILIKE ? OR doi = '' OR doi IS NULL)) OR (doi ILIKE ? AND doi != '')},
                                     "#{publication.title}#{publication.secondary_title}",
                                     publication.published_on.try(:year),
                                     publication.doi,
                                     publication.doi)
                     .where.not(id: publication.non_duplicate_groups.map { |g| g.memberships.map(&:publication_id) }.flatten).or(Publication.where(id: publication.id))
                 end

    group_publications(duplicates)
  end

  def self.group_publications(publications)
    if publications.many?
      existing_groups = publications.select { |p| p.duplicate_group.present? }.map(&:duplicate_group)
      group_to_remain = existing_groups.first
      groups_to_delete = existing_groups - [group_to_remain]
      pubs_to_regroup = groups_to_delete.map(&:publications).flatten

      ActiveRecord::Base.transaction do
        if group_to_remain
          publications.each do |p|
            p.update!(duplicate_group: group_to_remain) if p.duplicate_group.blank?
          end
          pubs_to_regroup.each do |p|
            p.update!(duplicate_group: group_to_remain)
          end
          groups_to_delete.each(&:destroy)
        else
          create!(publications: publications)
        end
      end
    end
  end

  def self.auto_merge
    pbar = Utilities::ProgressBarTTY.create(title: 'Auto-merging Pure and AI groups',
                                            total: count)

    find_each do |g|
      g.auto_merge
      pbar.increment
    end

    pbar.finish
    nil
  end

  def auto_merge
    if publication_count == 2
      pure_pub = publications.find(&:has_single_import_from_pure?)
      ai_pub = publications.find(&:has_single_import_from_ai?)

      if !pure_pub.nil? && !ai_pub.nil?
        search = Publication.where(%{similarity(CONCAT(title, secondary_title), ?) >= 0.6}, "#{pure_pub.title}#{pure_pub.secondary_title}")
        if search.include?(ai_pub)
          ActiveRecord::Base.transaction do
            ai_pub.imports.each do |i|
              i.update!(auto_merged: true)
            end
            pure_pub.merge!([ai_pub])
            pure_pub.update!(duplicate_group: nil)
            destroy
          end
          true
        else
          false
        end
      else
        false
      end
    else
      false
    end
  rescue StandardError => e
    Rails.logger.error e.message
  end

  def self.auto_merge_matching
    pbar = Utilities::ProgressBarTTY.create(title: 'Auto-merging duplicate groups on doi',
                                            total: count)

    find_each do |g|
      g.auto_merge_matching
      pbar.increment
    end

    pbar.finish
    nil
  end

  def auto_merge_matching
    publications.each do |pub_primary|
      publications.each do |pub|
        next if pub_primary.id == pub.id

        # The primary publication stored in memory may have changed so reload it
        begin
          pub_primary.reload
        # The primary publication may have been deleted so rescue RecordNotFound and move to the next iteration
        rescue ActiveRecord::RecordNotFound
          next
        end

        match_policy = if pub_primary.doi.present? && pub.doi.present?
                         PublicationMatchOnDOIPolicy.new(pub_primary, pub)
                       else
                         PublicationMatchMissingDOIPolicy.new(pub_primary, pub)
                       end
        if match_policy.ok_to_merge?
          begin
            ActiveRecord::Base.transaction do
              pub.imports.each do |i|
                i.update!(auto_merged: true)
              end
              pub_primary.merge_on_matching!(pub)
            end
          rescue Publication::NonDuplicateMerge; end
        end

        if reload.publications.count == 1
          pub_primary.update!(duplicate_group: nil)
          destroy
        end
      end
    rescue StandardError => e
      Rails.logger.error e.message
    end
  end

  rails_admin do
    configure :publications do
      pretty_value do
        bindings[:view].render partial: 'rails_admin/partials/duplicate_publication_groups/publications', locals: { publications: value }
      end
    end

    list do
      field(:id) { sort_reverse false }
      field(:first_publication_title) { label 'Title of first duplicate' }
      field(:publication_count) { label 'Number of duplicates' }
    end

    show do
      field(:id)
      field(:created_at)
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
