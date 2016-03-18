require 'spec_helper'

describe 'the job "Timeout Demo"', type: :feature do

  before :all do
    setup_signin_waitforcommits
    run_job_on_last_commit 'Timeout Demo'
    wait_for_job_state 'Timeout Demo', 'defective'
    @job_id = find('#job')['data-id']
  end

  it 'fails the "Fail Timeout" task but passes the other' do
    visit path_to_job(@job_id)
    find('select#tasks_select_condition').select('All')
    click_on('Filter')

    expect(
      find('td', text: 'Fail Timeout').find(:xpath, '..')['data-state']
    ).to be == 'defective'

    expect(
      find('td', text: 'Pass Timeout').find(:xpath, '..')['data-state']
    ).to be == 'passed'
  end

  it 'the scripts for the task "Fail Timeout" are in proper order and state', driver: :selenium do
    visit path_to_job(@job_id)
    find('select#tasks_select_condition').select('All')
    click_on('Filter')
    click_on('Fail Timeout')
    expect(all('li.script').map { |e| e['data-state'] }).to be == \
      %w(defective skipped)
  end

  it 'the scripts for the task "Pass Timeout" are in proper order and state', driver: :selenium do
    visit path_to_job(@job_id)
    find('select#tasks_select_condition').select('All')
    click_on('Filter')
    click_on('Pass Timeout')
    expect(all('li.script').map { |e| e['data-state'] }).to be == \
      %w(passed passed)
  end


end
