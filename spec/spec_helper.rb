require 'active_support/all'
require 'logger'
require 'faker'
require 'pry'

require 'config/database'
require 'config/browser'
require 'config/factories'
require 'helpers/system'
require "config/screenshots"

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

    config.before(:each) do |example|
      Helpers::DemoExecutor.reset_config
    end

    config.after(:all) do |example|
      Helpers::DemoExecutor.reset_config
    end

    config.after(type: :feature) do |example|
      if ENV["CIDER_CI_TRIAL_ID"].present?
        unless example.exception.nil?
          take_screenshot("tmp")
        end
      end
      page.driver.quit
      Capybara.current_driver = Capybara.default_driver
    end


  end
end
