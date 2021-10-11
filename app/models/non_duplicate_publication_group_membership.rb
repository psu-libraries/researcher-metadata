# frozen_string_literal: true

class NonDuplicatePublicationGroupMembership < ApplicationRecord
  belongs_to :publication, inverse_of: :non_duplicate_group_memberships
  belongs_to :non_duplicate_group,
             class_name: :NonDuplicatePublicationGroup,
             foreign_key: :non_duplicate_publication_group_id,
             inverse_of: :memberships
end
