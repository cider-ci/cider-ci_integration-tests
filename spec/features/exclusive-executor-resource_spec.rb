require 'spec_helper'
require 'shared/push_and_pull'

describe 'The Exclusive Executor Resource in normal mode', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end
  it 'passes when being run' do
    run_job_on_last_commit 'Exclusive Executor Resource'
    wait_for_job_state 'Exclusive Executor Resource', 'passed'
  end
end
