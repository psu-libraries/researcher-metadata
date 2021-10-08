# frozen_string_literal: true

class EmailError < ApplicationRecord
  belongs_to :user
end
