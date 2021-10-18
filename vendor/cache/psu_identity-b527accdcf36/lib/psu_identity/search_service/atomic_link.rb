# frozen_string_literal: true

module PsuIdentity::SearchService
  class AtomicLink < OpenStruct
    def to_s
      href
    end
  end
end
