require 'spec_helper'
require 'fileutils'

describe 'After setting short retention times ',
  type: :feature  do

  before :all do
    IO.write "../config/config.yml", {
      'job_retention_duration' => '90 Seconds',
      'task_retention_duration' => '60 Seconds',
      'trial_retention_duration' => '30 Seconds',
    }.to_yaml
  end

  after :all do
    FileUtils.rm  "../config/config.yml"
  end

  before :each do
    setup_signin_waitforcommits
  end


  it " and creating a job on the current branch " \
    " the trial will be deleted , then the task will be deleted, " \
    " but the job will stay." do
    run_job_on_last_commit 'JSON Demo'
    wait_for_job_state 'JSON Demo', 'passed'

    # there is one trial
    expect(all("ul.trials li").count).to be== 1
    # it will be removed
    wait_until(60){all("ul.trials li").count == 0}

    # there is still one tasks
    expect(all("table#tasks-table tr").count).to be== 1
    # it will be removed
    wait_until{all("table#tasks-table tr").count == 0}

    # there is till one job
    click_on_first "Workspace"
    expect(all("table#jobs-table tr").count).to be== 1
    sleep 45
    expect(all("table#jobs-table tr").count).to be== 1

  end

end
