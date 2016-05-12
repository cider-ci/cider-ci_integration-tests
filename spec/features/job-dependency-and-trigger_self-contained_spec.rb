require 'spec_helper'

describe(" Given: job2 depends on job1 and is triggerd by job1.
           Facts: Job2 can not be run if job1 has not passed.
           Job2 will be automatically started when job1 has passed.
           ".strip_heredoc, type: :feature) do

  before :each do
    setup_signin_waitforcommits
  end

  let :cider_ci_config do <<-YAML.strip_heredoc
    jobs:
      job1:
        task: |
          :; exit 0
          exit /b 0
      job2:
        task: |
          :; exit 0
          exit /b 0
        depends_on:
          "job1 has passed":
            type: job
            job_key: job1
            states: [passed]
        run_when:
          "job1 has passed":
            type: job
            job_key: job1
            states: [passed]
    YAML
  end

  let :message do
    'Job dependencies and triggers'
  end

  it '' do

    sign_in_as 'admin'

    Helpers::DemoRepo.reset!

    Dir.chdir Helpers::DemoRepo.system_path do
      File.open("cider-ci.yml", 'w') do |file|
        file.write cider_ci_config
      end
    end

    Helpers::DemoRepo.exec! <<-CMD.strip_heredoc
        git add --all .
        git commit -m #{Shellwords.escape message}
        CMD

    click_on_first 'Workspace'
    wait_until { page.has_content? message }

    click_on_first "Run"

    # job2 can not be run because it depends on job1
    expect(find(".un-runnable-job")).to have_content /job.*dependency.*job1.*not fulfilled/

    # run job1 and wait for it to pass
    click_on_first "Run"
    wait_for_job_state("job1","passed")

    # job2 dependency is fulfilled and it has been started
    click_on_first "Workspace"
    wait_for_job_state("job2","passed")

  end

end
