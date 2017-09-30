require 'spec_helper'

describe 'The JSON Demo', type: :feature  do
  before :each do
    setup_signin_waitforcommits
  end
  it 'passes when being run' do
    run_job_on_last_commit 'JSON Demo'
    wait_for_job_state 'JSON Demo', 'passed'
  end
end
