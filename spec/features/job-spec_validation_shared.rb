require 'spec_helper'

shared_examples :generic_job_spec_validation_fail do |custom_expectations|

  describe 'violates the validation of the job-specification', type: :feature do

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


    let :message do
      "Replaced by #{job_name}".truncate(20)
    end

    it 'ends up defective and has a corresponding issue.' do
      Helpers::DemoRepo.reset!
      Dir.chdir Helpers::DemoRepo.system_path do
        File.open("cider-ci.yml", 'w') do |file|
          file.write cider_ci_config        end
      end

      Helpers::DemoRepo.exec! <<-CMD.strip_heredoc
        git add --all .
        git commit -m #{Shellwords.escape message}
        CMD
        sign_in_as 'admin'
        click_on_first 'Workspace'
        wait_until { page.has_content? message }
        run_job_on_last_commit job_name
        wait_for_job_state job_name, 'defective'

        # there is a job-issue-warning for the job on the workspace
        click_on_first "Workspace"
        wait_until(1){ first("tr.job a .job-issue-warning")}

        # the job issue is shown as an alert on the job page
        first("tr.job a").click
        job_path = current_path

        expect(find(".alert-danger")).to have_content /Error: Validation Error/

        #expect(find(".alert")).to have_content
        #/The following key\(s\) are not allowed.*bogus.*/

        eval custom_expectations if custom_expectations.present?
    end
  end
end

