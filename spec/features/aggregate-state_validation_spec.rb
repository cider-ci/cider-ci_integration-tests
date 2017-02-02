require 'spec_helper'

feature 'Aggregate State Feature for Validation typo', type: :feature do
  let :job_name do
    'Aggregate State with Typo'
  end

  scenario 'It defects with an valiation error' do
    setup_signin_waitforcommits
    run_job_on_last_commit job_name
    wait_for_job_state job_name, 'defective'

    # and the page shows a validation error
    expect(page).to have_content 'Validation Error'

  end
end
