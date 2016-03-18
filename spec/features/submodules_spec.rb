
require 'spec_helper'

describe 'the job "Submodule Demo" ', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end
  it 'passes' do
    sign_in_as 'admin'
    run_job_on_last_commit 'Submodule Demo'
    wait_for_job_state 'Submodule Demo', 'passed'
  end
end
