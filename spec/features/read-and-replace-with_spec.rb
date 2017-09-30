require 'spec_helper'

describe 'Read and Replace With Demo', type: :feature  do
  before :each do
    setup_signin_waitforcommits
  end
  it 'passes when being run' do
    run_job_on_last_commit 'Read and Replace With Demo'
    wait_for_job_state 'Read and Replace With Demo', 'passed'
  end
end
