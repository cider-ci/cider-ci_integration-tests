require 'spec_helper'
require 'fileutils'

describe 'After setting short retention times ',
  type: :feature  do

  before :each do
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


  it " and creating a job on a non branch commit" \
    " the trial, then the task and then the job will be deleted." do
    find('select#depth').select('Any depth')
    click_on "Filter"
    find('table#commits-table tr:nth-child(2) td.tree-objects-link a').click
    click_on "Run job"

    find(".runnable-job[data-name='JSON Demo']").find('a,button', text: 'Run').click
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
    # it will be removed
    wait_until{all("table#jobs-table tr").count == 0}

  end
end
