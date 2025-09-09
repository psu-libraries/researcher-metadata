# frozen_string_literal: true

class Source
  USER = 'user'
  SCHOLARSPHERE = 'scholarsphere'
  OPEN_ACCESS_BUTTON = 'open_access_button'
  UNPAYWALL = 'unpaywall'
  DICKINSON_IDEAS = 'dickinson_ideas'
  PSU_LAW_ELIBRARY = 'psu_law_elibrary'
  DICKINSON_INSIGHT = 'dickinson_insight'

  def initialize(source)
    @source = source
  end

  def ==(other)
    to_s == other.to_s
  end
  alias :eql? :==

  def display
    I18n.t(
      @source,
      scope: [:source],
      default: @source.to_s.humanize.titleize
    )
  end

  def to_s
    @source
  end
end
