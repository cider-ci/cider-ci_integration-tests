require 'spec_helper'

describe 'the job "Depending and Ignoring Scripts Demo" ', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end
  it 'passes, the scripts have proper state and order' do
    sign_in_as 'adam'
    run_job_on_last_commit 'Depending and Ignoring Scripts Demo'
    wait_for_job_state 'Depending and Ignoring Scripts Demo', 'failed'

    find('select#tasks_select_condition').select('All')
    click_on('Filter')


    expect(
      find('td', text: "All in one").find(:xpath, '..')['data-state']
    ).to be == 'passed'

    expect(
      first('td', text: "Fail").find(:xpath, '..')['data-state']
    ).to be == 'failed'

    expect(
      first('td', text: "Fail and ignore").find(:xpath, '..')['data-state']
    ).to be == 'passed'

    expect(
      first('td', text: "Skip").find(:xpath, '..')['data-state']
    ).to be == 'failed'

    expect(
      first('td', text: "Skip but ignore").find(:xpath, '..')['data-state']
    ).to be == 'passed'


    click_on('All in one')

    first('tr.trial a').click

    expect(all('li.script').map { |e| e['data-name'] }).to be == \
      ['script-root', 'script-depending-root-passed', 'script-failing',
       'script-depend-failing-failed', 'script-depend-failing-failed-passed']

    expect(all('li.script').map { |e| e['data-state'] }).to be == \
      %w(passed passed failed passed skipped)

    ts = all('li.script').map { |e| e['data-started-at'] }.select { |x| x } \
         .map { |t| Time.iso8601(t) }
    expect(ts).to be == ts.sort
  end
end
