require 'spec_helper'

describe 'the job "Contexts Demo"', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end
  it 'passes, and includes the defined tasks' do
    sign_in_as 'adam'
    run_job_on_last_commit 'Contexts Demo'
    wait_for_job_state 'Contexts Demo', 'passed'

    find('select#tasks_select_condition').select('All')
    click_on('Filter')

    expect(
      find('td', text: "Earth check").find(:xpath, '..')['data-state']
    ).to be == 'passed'

    expect(
      find('td', text: "Io check").find(:xpath, '..')['data-state']
    ).to be == 'passed'

    expect(
      first('td', text: "Jupiter check").find(:xpath, '..')['data-state']
    ).to be == 'passed'

  end
end
