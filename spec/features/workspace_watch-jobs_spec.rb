require 'spec_helper'

describe 'Watching jobs in the workspace', type: :feature do

  it 'shows job icon inside the commit tr and a job row' do
    setup_signin_waitforcommits
    first('a.run-a-job').click
    find(".runnable-job[data-name='Script Dependencies']")
      .find('a,button', text: 'Run').click
    click_on_first 'Workspace'
    wait_until { all('table#jobs-table tr.job.failed').count > 0 }
    expect(find("tr.commit li.job[data-state='failed']")).to be
  end

end
