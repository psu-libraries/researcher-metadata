# frozen_string_literal: true

# We'll use the Rack::Test driver by default, and a headless chrome driver for tests tagged with javascript.
module DownloadHelpers
  DIRECTORY = Pathname.pwd.join('tmp/downloads').to_s

  def clear_downloads
    FileUtils.rm_rf(DIRECTORY)
    FileUtils.mkdir_p(DIRECTORY)
  end

  def wait_for_downloads
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until download_finished?
    end
  end

  def download_finished?
    !download_directory.empty?
  end

  def download_directory
    Pathname.new(DIRECTORY)
  end
end

RSpec.configure do |config|
  config.include DownloadHelpers

  Capybara.javascript_driver = :rmd_chrome_headless
end

# Force Selenium Manager to bypass the root directory and use /tmp instead
ENV['SE_CACHE_PATH'] = '/tmp/selenium_cache'

# This is a modified version of :selenium_chrome_headless copied from lib/capybara/registrations/drivers.rb so we can
# monitor a directory for downloaded files.
Capybara.register_driver :rmd_chrome_headless do |app|
  version = Capybara::Selenium::Driver.load_selenium
  browser_options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.binary = "/usr/bin/google-chrome-stable"
    opts.add_argument('--headless=new') # 'new' headless mode, required for Chrome >= 112
    opts.add_argument('--disable-gpu') if Gem.win_platform?
    opts.add_argument('--disable-site-isolation-trials')
    opts.add_argument('--disable-setuid-sandbox')
    opts.add_argument('--no-sandbox')
    opts.add_argument('--remote-debugging-pipe')
    opts.add_argument('--disable-dev-shm-usage') # recommended for Docker/CI
    opts.add_preference(:download, prompt_for_download: false, default_directory: DownloadHelpers::DIRECTORY)
    opts.add_preference(:browser, set_download_behavior: { behavior: 'allow' })
  end

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end
