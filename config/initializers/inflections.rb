# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'CSV'
  inflect.acronym 'API'
  inflect.acronym 'PSU'
  inflect.acronym 'ETD'
  inflect.acronym 'DOI'
  inflect.acronym 'WOS'
  inflect.acronym 'URLs'
  inflect.acronym 'HR'
  inflect.acronym 'OAI'
  inflect.acronym 'OAB'
  inflect.acronym 'OA'
  inflect.acronym 'NSF'
  inflect.acronym 'LDAP'
  inflect.acronym 'URL'
  inflect.acronym 'ISBN'
  inflect.acronym 'ISSN'
  inflect.acronym 'IO'
end
