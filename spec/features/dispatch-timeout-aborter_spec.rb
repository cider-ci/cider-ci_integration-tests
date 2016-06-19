require 'spec_helper'
require 'fileutils'

describe 'A trial passing the trial_dispatch_timeout will be set to '\
  'aborted, no retry will be performed and an trial issue will be set.',
  type: :feature  do

  def job_name
    'Unsatisfiable Trait'
  end

  def cider_ci_config
    <<-YAML.strip_heredoc
      jobs:
        test:
          name: '#{job_name}'
          context:
            tasks:
              task1:
                traits:
                  Bogus: true
                scripts:
                  script1:
                    body: exit 0
    YAML
  end

  def message
    "Replaced by #{job_name}".truncate(20)
  end

  before :all do
    IO.write "../config/config.yml", {
      'trial_dispatch_timeout' => '10 Seconds',
    }.to_yaml
  end

  after :all do
    FileUtils.rm  "../config/config.yml"
  end

  before :each do
    setup_signin_waitforcommits

    Helpers::DemoRepo.reset!
    Dir.chdir Helpers::DemoRepo.system_path do
      IO.write "cider-ci_v4.yml", cider_ci_config
    end

    Helpers::DemoRepo.exec! <<-CMD.strip_heredoc
      git add --all .
      git commit -m #{Shellwords.escape message}
    CMD

  end


  it "so happens" do
    sign_in_as 'admin'
    click_on_first 'Workspace'
    wait_until { page.has_content? message }
    run_job_on_last_commit job_name
    wait_for_job_state job_name, 'aborted'
    expect(all("tr.task td.trials li").count).to be== 1
    expect(find("tr.task td.trials li")['data-state']).to be== 'aborted'
    find("tr.task td.trials li a").click
    expect(page).to have_content "This trial has 1 issue!"
  end
end
