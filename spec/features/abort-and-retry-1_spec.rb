require 'spec_helper'

describe 'Abort and retry a job', type: :feature do
  let :abort_and_retry_job do
    'Abort and Retry Demo'
  end

  it "Running, and then aborting a job ends in the state 'aborted' " \
    ",and then retrying the job ends in the state 'passed'" do
    setup_signin_waitforcommits
    run_job_on_last_commit abort_and_retry_job
    wait_until do
      all("ul.trials li.trial[data-state='executing']").count > 0
    end
    click_on 'Abort'
    expect(first("ul.trials li.trial[data-state='aborting']")).to be
    wait_for_job_state abort_and_retry_job, 'aborted'

    # check the "aborted by" info is shown for the job
    expect(find('#job-info .aborted').text).to match /aborted .* by Adam Ambassador/

    job_path = current_path
    # all trials must be aborted after some time
    expect(all('ul.trials li.trial').map { |x| x['data-state'] } \
           .all? { |x| x == 'aborted' }).to be true

    # check that the "aborted by" info is shown for the trial
    first(".trial[data-state='aborted'] a").click
    expect(find('#trial-info .aborted').text).to match /aborted .* by Adam Ambassador/

    visit job_path
    click_on 'Retry & Resume'
    wait_for_job_state abort_and_retry_job, 'passed', wait_time: 90, forbidden_terminal_states: []

    # check the "resumed by" info is shown for the job
    expect(find('#job-info .resumed').text).to match /resumed.* by Adam Ambassador/

    # check that the "created by" (= retry) info is shown for the trial
    first(".trial[data-state='passed'] a").click
    expect(find('#trial-info .created').text).to match /created .* by Adam Ambassador/

    # check that the trial of a manual task retry shows "created by"
    click_on 'Retry'
    expect(page).to have_content 'A new trial has been created.'
    expect(find('#trial-info .created').text).to match /created .* by Adam Ambassador/
  end
end
