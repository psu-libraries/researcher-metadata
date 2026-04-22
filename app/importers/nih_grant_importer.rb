# frozen_string_literal: true

module NIHGrantImporter
  def self.call
    NIHProjects.find_in_batches do |p|
      # This is a placeholder for the actual importing logic which is not
      # yet fully designed.
      puts p.identifier
    end
  end
end
