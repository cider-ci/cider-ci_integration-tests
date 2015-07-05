require 'spec_helper'

describe 'Accepted Repositories', type: :feature do
  before :each do
    setup_signin_waitforcommits
  end

  it 'The job will not be dispatched unless ' \
    'the git_url is one of the accepted ones' do
    job_name = 'Environment Variables Demo'
    sign_in_as 'adam'
    Helpers::DemoExecutor.set_accepted_repositories \
      ['http://nonsense.com/blah']
    run_job_on_last_commit job_name
    job_path = current_path
    sleep 30
    visit job_path
    wait_for_job_state job_name, 'pending'
    Helpers::DemoExecutor.set_accepted_repositories \
      ['http://nonsense.com/blah', Helpers::DemoRepo.git_url]
    sleep 5
    visit job_path
    wait_for_job_state job_name, 'passed'
  end

  it 'The executor will refuse trials for not accepted git urls ' do
    job_name = 'Environment Variables Demo'
    sign_in_as 'adam'
    Helpers::DemoExecutor.set_accepted_repositories \
      ['http://nonsense.com/blah']
    run_job_on_last_commit job_name
    job_path = current_path
    10.times do
      cmd = 'Executor.first.update_attributes!(' \
        "accepted_repositories: ['#{Helpers::DemoRepo.git_url}'])"
      Helpers::ConfigurationManagement.invoke_ruby cmd
      sleep 1
    end
    visit job_path
    wait_for_job_state job_name, 'failed'
  end
end
