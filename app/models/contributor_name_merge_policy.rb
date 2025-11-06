# frozen_string_literal: true

class ContributorNameMergePolicy
  def initialize(contributor_names)
    @contributor_names = contributor_names
  end

  def contributor_names_to_keep
    uniqued_by_user_id = user_id_uniqued(contributor_names)

    uniqued_by_user_id.group_by { |cn| [cn.first_name&.first&.downcase, cn.last_name&.downcase, cn.position] }
      .values
      .map { |group| preferred_contributor_name(group) }
  end

  private

    def user_id_uniqued(names)
      grouped = names.group_by(&:user_id)
      grouped.each do |key, value|
        if key.present? && value.many?
          grouped[key] = select_from_preferred_source(value)
        end
      end
      grouped.values.flatten
    end

    def select_from_preferred_source(cn_group)
      filter1 = cn_group.select { |cn| cn.publication.pure_import_identifiers.present? }.presence || cn_group

      filter2 = filter1.select { |cn| cn.publication.ai_import_identifiers.present? }.presence || filter1

      filter2.sample
    end

    def preferred_contributor_name(cn_group)
      filter1 = cn_group.select { |cn| cn.user_id.present? }.presence || cn_group

      filter2 = filter1.select { |cn| cn.role.present? }.presence || filter1

      grouped_by_name = filter2.group_by(&:name)
      preferred_name_group = grouped_by_name.max_by { |k, _v| k.length }
      preferred_name_group.last.first
    end

    attr_accessor :contributor_names
end
