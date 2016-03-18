require 'faraday'
require 'git'
require 'spec_helper'
require 'uri'


describe 'Project configuration normalization', type: :feature do

  before :each do
    setup_signin_waitforcommits
  end

  let :config_files do
    %w(cider-ci.yml .cider-ci.yml cider-ci.json .cider-ci.json)
  end

  let :conn do
    base_url = "#{Capybara.app_host}/cider-ci/"
    Faraday.new(base_url) do |conn|
      conn.basic_auth('test-service', ENV['SERVICES_SECRET'])
      conn.adapter Faraday.default_adapter
    end
  end

  def delete_all_config_files
    config_files.each do |filename|
      Helpers::DemoRepo.remove_file filename
    end
  end

  context 'A job with an illegal context' do

    let :job_name do
      'Job with illegal context'
    end

    let :message do
      'Replaced by "Job without context"'
    end

    it 'running results in an error and a tree issue' do
      Helpers::DemoRepo.reset!
      Dir.chdir Helpers::DemoRepo.system_path do
        File.open("cider-ci.yml", 'w') do |file|
          file.write <<-YAML.strip_heredoc
            jobs:
              test:
                name: #{job_name}
                context: "blah"
                YAML
        end
      end
      Helpers::DemoRepo.exec! <<-CMD.strip_heredoc
        git add --all .
        git commit -m #{Shellwords.escape message}
        CMD
        sign_in_as 'admin'
        click_on_first 'Workspace'
        wait_until { page.has_content? message }
        run_job_on_last_commit job_name

        # a alert says that "The creation of a new job failed"
        wait_until { first ".alert", text: "The creation of a new job failed" }
        # and hints to the cause 'Project Configuration Normalization Error'
        wait_until { first ".alert", text: 'Project Configuration Normalization Error' }

        # there will be a tree issue
        wait_until { first  "a .tree-issue-warning" }.click

        # the tree issue refers to a 'Project Configuration Normalization Error'
        wait_until { first ".alert", text: 'Project Configuration Normalization Error' }

    end
  end
end
