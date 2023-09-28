# frozen_string_literal: true

class OABPermission
  def initialize(data)
    @data = data
  end

  def version
    data['version']
  end

  def can_archive_in_institutional_repository?
    data['can_archive'] == true && data['locations'].map(&:downcase).include?('institutional repository')
  end

  def has_requirements?
    !!data['requirements'].try(:any?)
  end

  private

    attr_reader :data
end
