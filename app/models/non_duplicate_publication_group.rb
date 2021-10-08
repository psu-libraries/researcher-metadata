# frozen_string_literal: true

class NonDuplicatePublicationGroup < ApplicationRecord
  has_many :memberships,
           class_name: :NonDuplicatePublicationGroupMembership,
           inverse_of: :non_duplicate_group
  has_many :publications, through: :memberships
end
