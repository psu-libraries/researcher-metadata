# frozen_string_literal: true

class Tag < ApplicationRecord
  before_validation :titleize_name

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :publication_taggings, inverse_of: :tag
  has_many :publications, through: :publication_taggings

  private

    def titleize_name
      self.name = name.downcase.titleize if name.present?
    end
end
