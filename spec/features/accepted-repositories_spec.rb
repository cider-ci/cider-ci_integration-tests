require 'spec_helper'
require 'shared/push_and_pull'

shared_examples :accepted_repositories do
  it 'The job will not be dispatched unless ' \
    'the git_url is one of the accepted ones' do
    job_name = 'Contexts Demo'
    sign_in_as 'admin'
    Helpers::DemoExecutor.set_accepted_repositories \
      ['http://nonsense.com/blah']
    sleep 5
    run_job_on_last_commit job_name
    job_path = current_path
    sleep 20
    visit job_path
    wait_for_job_state job_name, 'pending'
    Helpers::DemoExecutor.set_accepted_repositories \
      ['http://nonsense.com/blah', Helpers::DemoRepo.git_url]
    sleep 5
    visit job_path
    wait_for_job_state job_name, 'passed'
  end
end

describe 'Dispatching and running in ', type: :feature do
  include_context :run_in_push_and_pull_mode,
                  :accepted_repositories
end
