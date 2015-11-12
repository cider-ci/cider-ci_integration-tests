require 'spec_helper'

describe 'the job "Script Dependencies" Demo ', type: :feature do
  before :all do
    setup_signin_waitforcommits
    run_job_on_last_commit 'Script Dependencies'
    wait_for_job_state 'Script Dependencies', 'failed'
    @job_id = find('#job')['data-id']

    find('select#tasks_select_condition').select('All')
    click_on('Filter')
    click_on('Comprehensive')
    first('tr.trial a').click
    @comprehensive_trial_path = current_path
  end

  before :each do
    sign_in_as 'admin'
    visit @comprehensive_trial_path
  end

  it 'the start dependency graph visualization for a trial of "Comprehensive" ' do
    click_on 'Start-Dependencies'

    # svg exists
    first('svg')

    # it has the expected elements"
    failing_node = find('#failing')
    expect(failing_node.find('text').text).to be == 'Failing'
    expect(failing_node[:class].split(/\s+/)).to include 'node'
    expect(failing_node[:class].split(/\s+/)).to include 'failed'

    root_to_failing_edge = find('#root_failing')
    expect(root_to_failing_edge[:class].split(/\s+/)).to include 'edge'
    expect(root_to_failing_edge.find('text').text).to be == 'passed'
  end

  it 'the Gantt-Chart for a trial of "Comprehensive" ' do
    click_on 'Gantt-Chart'
    first('svg')
    find('rect.script.failed')
  end

  it 'the terminate dependency graph visualization for a trial of "Termination"' do
    visit path_to_job(@job_id)
    click_on('Termination')
    first('tr.trial a').click
    click_on('Terminate-Dependencies')
    initial_node = find('#initial')
    expect(initial_node[:class].split(/\s+/)).to include 'node'
    expect(initial_node[:class].split(/\s+/)).to include 'passed'
    # edge exists too
    first('.edge')
  end
end
