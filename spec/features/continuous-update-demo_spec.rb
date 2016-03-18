require 'spec_helper'

context 'Continuous Output Update Demo', type: :feature do
  it 'stdout and stderr get continuously updated and the job passes' do
    setup_signin_waitforcommits

    run_job_on_last_commit 'Continuous Output Update Demo'
    @job_id = find('#job')['data-id']

    click_on('task')
    first('tr.trial a').click
    click_on('script')

    wait_until do
      find('#stderr pre').has_content? 'Message 1 to stderr'
      find('#stdout pre').has_content? 'Message 1 to stdout'
    end

    expect('#stderr pre').not_to have_content 'Message 300 to stderr'
    expect('#stdout pre').not_to have_content 'Message 300 to stderr'

    wait_until do
      find('#stderr pre').has_content? 'Message 300 to stderr'
      find('#stdout pre').has_content? 'Message 300 to stdout'
    end

    visit path_to_job(@job_id)

    wait_for_job_state 'Continuous Output Update Demo', 'passed'
  end
end

