# frozen_string_literal: true

class ContributorNameMergePolicy
  def initialize(contributor_names)
    @contributor_names = contributor_names
  end

  def contributor_names_to_keep
    contributor_names.group_by { |cn| [cn.first_name&.first, cn.last_name] }
        .values
        .collect { |group| preferred_contributor_name(group) }
  end

  private

    def preferred_contributor_name(cn_group)
      filter1 = cn_group.collect { |cn| cn if cn.user_id.present? }.compact.present? ?
                    cn_group.collect { |cn| cn if cn.user_id.present? }.compact :
                    cn_group

      filter2 = filter1.collect { |cn| cn if cn.role.present? }.compact.present? ?
                    filter1.collect { |cn| cn if cn.role.present? }.compact :
                    filter1

      filter3 = filter2.collect { |cn| cn if cn.position.present? }.compact.present? ?
                    filter2.collect { |cn| cn if cn.position.present? }.compact :
                    filter2

      grouped_by_name = filter3.group_by { |cn| cn.name }
      preferred_name_group = grouped_by_name.max_by { |k, _v| k.length }
      preferred_name_group.last.first
    end


    attr_accessor :contributor_names
end