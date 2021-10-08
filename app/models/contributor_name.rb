# frozen_string_literal: true

class ContributorName < ApplicationRecord
  belongs_to :publication, inverse_of: :contributor_names
  belongs_to :user, inverse_of: :contributor_names, optional: true

  validates :publication, :position, presence: true
  validate :at_least_one_name_present

  delegate :webaccess_id, to: :user, prefix: false, allow_nil: true

  def name
    full_name = first_name.to_s
    full_name += ' ' if first_name.present? && middle_name.present?
    full_name += middle_name.to_s if middle_name.present?
    full_name += ' ' if middle_name.present? && last_name.present? || first_name.present? && last_name.present?
    full_name += last_name.to_s if last_name.present?
    full_name
  end

  def to_scholarsphere_creator
    ss_attrs = {}
    ss_attrs[:psu_id] = webaccess_id if webaccess_id
    ss_attrs[:orcid] = orcid_identifier if orcid_identifier
    ss_attrs[:display_name] = name if name.present?
    ss_attrs.presence
  end

  private

    def orcid_identifier
      user.try(:orcid).try(:gsub, '-', '')
    end

    def at_least_one_name_present
      unless first_name.present? || middle_name.present? || last_name.present?
        errors[:base] << 'At least one name must be present.'
      end
    end
end
