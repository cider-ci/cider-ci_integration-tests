require 'spec_helper'

describe 'the job "Introduction Demo and Example" ', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end
  it 'passes' do
    sign_in_as 'admin'
    run_job_on_last_commit 'Introduction Demo and Example'
    wait_for_job_state 'Introduction Demo and Example', 'passed'
  end
end
