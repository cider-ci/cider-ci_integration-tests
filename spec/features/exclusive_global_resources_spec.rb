require 'spec_helper'

describe 'The Exclusive Global Resources Demo', type: :feature do
  it 'passes when being run' do
    setup_signin_waitforcommits
    run_job_on_last_commit 'Exclusive Global Resources Demo'
    wait_for_job_state 'Exclusive Global Resources Demo', 'passed'
  end
end

