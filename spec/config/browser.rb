require 'selenium-webdriver'
require 'capybara/rspec'


RSpec.configure do |config|

  def set_browser example
    # Capybara.current_driver = :selenium
    Capybara.current_driver = \
      ENV['CAPYBARA_DRIVER'].presence.try(:to_sym) \
      || example.metadata[:driver] \
      || :selenium rescue :selenium
  end

  firefox_bin_path =
    Pathname.new(`asdf where firefox`.strip).join('bin/firefox').expand_path
  Selenium::WebDriver::Firefox.path = firefox_bin_path.to_s

  port = Integer(ENV['CIDER_CI_TEST_RV_HTTP_PORT'].present? &&
                 ENV['CIDER_CI_TEST_RV_HTTP_PORT'] || '3300')

  Capybara.current_driver = :selenium
  Capybara.app_host = "http://localhost:#{port}"
  Capybara.server_port = port

  config.before :all do |example|
    set_browser example
    Capybara.app_host = "http://localhost:#{port}"
    Capybara.server_port = port
  end

  config.before(:each) do |example|
    set_browser example
    Capybara.app_host = "http://localhost:#{port}"
    Capybara.server_port = port
  end


end

