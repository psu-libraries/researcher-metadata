# frozen_string_literal: true

module CachingHelpers
  def file_caching_path
    path = "tmp/test#{ENV.fetch('TEST_ENV_NUMBER', nil)}/cache"
    FileUtils::mkdir_p(path)

    path
  end
end
