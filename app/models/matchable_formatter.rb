# frozen_string_literal: true

class MatchableFormatter
  def initialize(value)
    @value = value
  end

  def format
    value&.downcase&.gsub(/[^a-z0-9]/, '')
  end

  private

    attr_reader :value
end
