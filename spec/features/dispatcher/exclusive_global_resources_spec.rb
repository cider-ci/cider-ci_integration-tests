require 'spec_helper'

describe 'the job "Exclusive Global Resources Demo" ', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end
  it 'passes' do
    sign_in_as 'adam'
    run_job_on_last_commit 'Exclusive Global Resources Demo'
    wait_for_job_state 'Exclusive Global Resources Demo', 'passed'
  end
end
