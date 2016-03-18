require 'spec_helper'

shared_examples :job_stayes_passed_when_last_trial_failed do |job_name|
  scenario "#{job_name} stays passed when the last trial failed" do
    setup_signin_waitforcommits
    run_job_on_last_commit job_name
    wait_for_job_state job_name, 'failed'

    job_path = current_path

    # the single trial failed and we do retry
    expect(all('.trial a').count).to be == 1

    first('.trial a').click
    expect(find('#trial-info .state')).to have_content 'failed'
    click_on 'Retry'
    expect(page).to have_content 'A new trial has been created.'
    wait_until { find('#trial-info .state').has_content? 'passed' }
    last_trial_path = current_path

    # now, the jobs has passed
    visit job_path
    expect(find('#job-info .state')).to have_content 'passed'

    # retry again (will fail) and check that the job is still passed
    visit last_trial_path
    click_on 'Retry'
    expect(page).to have_content 'A new trial has been created.'
    wait_until { find('#trial-info .state').has_content? 'failed' }
    visit job_path
    expect(find('#job-info .state')).to have_content 'passed'
  end
end
