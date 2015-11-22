require 'spec_helper'

feature 'Aggregate State Feature for Validation typo', type: :feature do
  let :job_name do
    'Aggregate State with Typo'
  end

  scenario 'It fails with an task error' do
    setup_signin_waitforcommits
    run_job_on_last_commit job_name
    wait_for_job_state job_name, 'failed'

    # the task has been aborted
    click_on 'task1'
    expect(find('#task-info .state')).to have_content 'aborted'
    # and the page shows a validation error
    expect(page).to have_content 'Validation Error'

    # there are no trials at all
    find('#trials table tbody')
    expect(all('#trials table tbody tr')).to be_empty
  end
end
