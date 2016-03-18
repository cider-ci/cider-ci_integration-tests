require 'spec_helper'

describe 'Abort and retry a job', type: :feature do
  let :abort_and_retry_job do
    'Abort and Retry Demo'
  end

  it 'Running a job and then orphan/detach the commit result in ' \
    'the job having been aborted' do
    setup_signin_waitforcommits

    expect(Helpers::DemoRepo.create_a_new_branch_and_commit_cmd(
             'orphaned_abort_test', 'asdfasdfas')).to pass_execution

    wait_until { page.has_content?('orphaned_abort_test') }

    run_job_on_last_commit abort_and_retry_job

    wait_until do
      all("ul.trials li.trial[data-state='executing']").count > 0
    end

    expect(Helpers::DemoRepo.delete_branch_cmd \
             'orphaned_abort_test').to pass_execution

    wait_for_job_state abort_and_retry_job, 'aborted'
  end
end
