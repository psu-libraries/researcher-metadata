module Capybara
  module Select2
    def select2(value, options = {})
      raise "Must pass a hash containing 'from' or 'xpath'" unless options.is_a?(Hash) and [:from, :xpath].any? { |k| options.has_key? k }

      if options.has_key? :xpath
        select2_container = first(:xpath, options[:xpath])
      else
        select_name = options[:from]
        select2_container = first("label", text: select_name).find(:xpath, '..').find(".select2-container")
      end

      select2_container.find(".select2-choice").click

      [value].flatten.each do |value|
        find(:xpath, "//body").find(".select2-drop li.select2-result-selectable", text: value).click
      end
    end
  end

  module WaitForAjax
    def wait_for_ajax
      Timeout.timeout(Capybara.default_wait_time) do
        loop until finished_all_ajax_requests?
      end
    end

    def finished_all_ajax_requests?
      page.evaluate_script('jQuery.active').zero?
    end
  end

  module WaitUntilVisible
    def wait_until_visible(selector)
      page.should have_selector(selector, visible: true)
    end
  end

  module SaveAndOpenScreenshot
    def save_and_open_screenshot(filename=nil)
      filename ||= "poltergeist-#{Time.new.strftime("%Y%m%d%H%M%S")}#{rand(10**10)}.png"
      path = File.expand_path(filename, ROOT.join('tmp/capybara'))

      page.save_screenshot(path, full: true)

      begin
        require "launchy"
        Launchy.open(path)
      rescue LoadError
        warn "Page saved to #{path} with save_and_open_page."
        warn "Please install the launchy gem to open page automatically."
      end

    end
  end
end

RSpec.configure do |config|
  config.include Capybara::Select2
  config.include Capybara::WaitForAjax
  config.include Capybara::WaitUntilVisible
  config.include Capybara::SaveAndOpenScreenshot
end
