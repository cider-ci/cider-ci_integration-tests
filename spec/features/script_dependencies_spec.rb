require 'spec_helper'

describe 'the job "Script-Dependencies-Demo" ', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end
  it 'passes, the scripts have proper state and order' do
    sign_in_as 'adam'
    run_job_on_last_commit 'Script-Dependencies-Demo'
    wait_for_job_state 'Script-Dependencies-Demo', 'passed'
    first('tr.task a').click
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
