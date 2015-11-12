require 'spec_helper'

describe 'the job "Templates Demo"', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end
  it 'fails the "Test Missing Template" but passes all others' do
    sign_in_as 'admin'
    run_job_on_last_commit 'Templates'
    wait_for_job_state 'Templates', 'failed'

    find('select#tasks_select_condition').select('All')
    click_on('Filter')

    expect(
      find('td', text: 'Simple Template').find(:xpath, '..')['data-state']
    ).to be == 'passed'

    expect(
      find('td', text: 'Templates and Ports').find(:xpath, '..')['data-state']
    ).to be == 'passed'

    expect(
      find('td', text: 'Test Missing Template').find(:xpath, '..')['data-state']
    ).to be == 'failed'

    expect(
      find('td', text: 'Test Recursive Templating').find(:xpath, '..')['data-state']
    ).to be == 'passed'
  end
end
