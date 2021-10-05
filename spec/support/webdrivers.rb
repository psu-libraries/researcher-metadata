require 'webdrivers/chromedriver'

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

# This is a modified version of :selenium_chrome_headless copied from lib/capybara/registrations/drivers.rb so we can
# monitor a directory for downloaded files.
Capybara.register_driver :rmd_chrome_headless do |app|
  version = Capybara::Selenium::Driver.load_selenium
  options_key = Capybara::Selenium::Driver::CAPS_VERSION.satisfied_by?(version) ? :capabilities : :options
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.add_argument('--headless')
    opts.add_argument('--disable-gpu') if Gem.win_platform?
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.add_argument('--disable-site-isolation-trials')
    opts.add_preference(:download, prompt_for_download: false, default_directory: DownloadHelpers::DIRECTORY)
    opts.add_preference(:browser, set_download_behavior: { behavior: 'allow' })
  end

  Capybara::Selenium::Driver.new(app, **Hash[:browser => :chrome, options_key => browser_options])
end

