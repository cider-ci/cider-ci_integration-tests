require 'spec_helper'

describe 'the job "Environment Variables Demo" ', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end
  it 'passes and exposes the current branch heads' do
    sign_in_as 'admin'
    run_job_on_last_commit 'Environment Variables Demo'
    wait_for_job_state 'Environment Variables Demo', 'passed'

    # test CIDER_CI_CURRENT_BRANCH_HEADS exposes the current
    # branch heads as present on the Cider-CI server
    click_on 'Set and Show Environment Variables'
    click_on 'show'
    expect(page).to have_content 'CIDER_CI_CURRENT_BRANCH_HEADS'
    expect(page).not_to have_content 'expose_branch_heads_test'
    click_on 'Trial'
    expect(Helpers::DemoRepo.create_new_branch('expose_branch_heads_test')).to \
      pass_execution
    sleep 10
    click_on 'Retry'
    wait_until{ first('li.state[data-state="passed"]') }
    click_on 'show'
    expect(page).to have_content 'expose_branch_heads_test'
  end
end
