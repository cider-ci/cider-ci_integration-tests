require 'spec_helper'

describe 'the job "Generate Tasks Demo" ', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end
  it 'passes' do
    sign_in_as 'admin'
    run_job_on_last_commit 'Generate Tasks Demo'
    wait_for_job_state 'Generate Tasks Demo', 'passed'
  end
end
