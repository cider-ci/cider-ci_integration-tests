require 'spec_helper'

describe 'the job "Environment Variables Demo" ', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end
  it 'passes' do
    sign_in_as 'admin'
    run_job_on_last_commit 'Environment Variables Demo'
    wait_for_job_state 'Environment Variables Demo', 'passed'
  end
end
