# frozen_string_literal: true

class PublicationYearSnapshot < ApplicationRecord
  belongs_to :statistics_snapshot
end
