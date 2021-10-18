# frozen_string_literal: true

require 'faraday'
require 'json'
require 'ostruct'

module PsuIdentity
  class Error < StandardError; end

  require 'psu_identity/search_service/atomic_link'
  require 'psu_identity/search_service/client'
  require 'psu_identity/search_service/person'
  require 'psu_identity/version'
end
