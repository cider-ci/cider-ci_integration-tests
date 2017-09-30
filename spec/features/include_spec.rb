
require 'spec_helper'

describe 'the job "Include Demo" ', type: :feature do
  before :each do
    setup_signin_waitforcommits
  end
  it 'passes' do
    sign_in_as 'admin'
    run_job_on_last_commit 'Include Demo'
    wait_for_job_state 'Include Demo', 'passed'
  end
end
