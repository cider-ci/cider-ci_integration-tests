require 'active_support/all'
require 'logger'
require 'faker'
require 'pry'

require 'config/database'
require 'config/browser'
require 'helpers/system'

TEST_BRANCH = 'v4'
TEST_COMMIT_ID = Helpers::System.exec!("
  #!/usr/bin/env bash
  cd ..
  git ls-tree HEAD demo-project-bash ").strip.split(/\s+/).map(&:strip)[2]


require 'matchers'
require 'helpers/configuration_management'
require 'helpers/demo_executor'
require 'helpers/demo_repo'
require 'helpers/misc'
require 'helpers/system_admin'
require 'helpers/users'


RSpec.configure do |config|
  config.include Helpers::DemoExecutor
  config.include Helpers::DemoRepo
  config.include Helpers::Misc
  config.include Helpers::Users


  config.before(:all) do |example|
    $logger = Logger.new(STDOUT)
    $logger.level = Logger::WARN
  end


  begin
    config.filter_run :focus
    config.run_all_when_everything_filtered = true
    config.warnings = false
    if config.files_to_run.one?
      config.default_formatter = 'doc'
    end

    config.order = :random

    Kernel.srand config.seed

    config.after(:each) do |example|
      unless example.exception.nil?
        take_screenshot
        unless ENV['CI'].presence || ENV['CIDER_CI_TRIAL_ID'].presence
          $logger.warn(example.exception.message)
          binding.pry
        end
      end
    end

    config.before(:each) do |example|
      Helpers::DemoExecutor.reset_config
    end

    config.after(:all) do |example|
      Helpers::DemoExecutor.reset_config
    end

    def take_screenshot(screenshot_dir = nil, name = nil)
      screenshot_dir ||= File.join(Dir.pwd, 'tmp')
      Dir.mkdir screenshot_dir rescue nil
      name ||= "screenshot_#{Time.now.iso8601.gsub(/:/, '-')}.png"
      path = File.join(screenshot_dir, name)
      case Capybara.current_driver
      when :selenium, :selenium_chrome
        page.driver.browser.save_screenshot(path) rescue nil
      else
        $logger.warn 'Taking screenshots is not implemented for ' \
        "#{Capybara.current_driver}."
      end
    end

  end
end
