require 'spec_helper'

describe 'the job "Script Dependencies" Demo ', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end

  before :all do
    setup_signin_waitforcommits
    run_job_on_last_commit 'Script Dependencies'
    wait_for_job_state 'Script Dependencies', 'failed'
    @job_id = find('#job')['data-id']
  end

  it 'produces the expected passings and failures ' do
    visit path_to_job(@job_id)
    find('select#tasks_select_condition').select('All')
    click_on('Filter')

    expect(
      find('td', text: "Comprehensive").find(:xpath, '..')['data-state']
    ).to be == 'passed'

    expect(
      first('td', text: "Fail").find(:xpath, '..')['data-state']
    ).to be == 'failed'

    expect(
      first('td', text: "Fail but ignore").find(:xpath, '..')['data-state']
    ).to be == 'passed'

    expect(
      first('td', text: "Skip").find(:xpath, '..')['data-state']
    ).to be == 'failed'

    expect(
      first('td', text: "Skip but ignore").find(:xpath, '..')['data-state']
    ).to be == 'passed'

    expect(
      first('td', text: "Start on Skipped").find(:xpath, '..')['data-state']
    ).to be == 'passed'

    expect(
      first('td', text: "Termination").find(:xpath, '..')['data-state']
    ).to be == 'failed'


  end

  it 'the scripts for the task "Comprehensive" are in proper order and state' do

    visit path_to_job(@job_id)
    find('select#tasks_select_condition').select('All')
    click_on('Filter')

    click_on('Comprehensive')
    first('tr.trial a').click
    expect(all('li.script').map { |e| e['data-name'] }).to be == \
      ['Root',  'Failing',  'Start when "failing" failed',  'Start when "failing" passed']
    expect(all('li.script').map { |e| e['data-state'] }).to be == \
      %w(passed failed passed skipped)
  end


  it 'the scripts for the task "Termination" are in proper order and state' do

    visit path_to_job(@job_id)
    find('select#tasks_select_condition').select('All')
    click_on('Filter')

    click_on('Termination')
    first('tr.trial a').click
    expect(all('li.script').map { |e| e['data-name'] }).to be == \
      ['Initial',  'Terminate when initial finished']
    expect(all('li.script').map { |e| e['data-state'] }).to be == \
      %w(passed failed)
  end


end
