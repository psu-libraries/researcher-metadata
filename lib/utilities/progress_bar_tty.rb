# frozen_string_literal: true

require 'ruby-progressbar/outputs/null'

# This is a thin wrapper around the progressbar gem that automatically hides
# the progressbar if the terminal is not interactive
# (tests, nohup jobs on the server, etc)

module Utilities
  class ProgressBarTTY
    def self.create(options = {})
      hidden = !$stdout.tty? || Rails.env.test?

      options[:output] = ProgressBar::Outputs::Null if hidden

      ProgressBar.create(options)
    end
  end
end
