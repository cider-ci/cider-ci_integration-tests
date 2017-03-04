require 'spec_helper'

describe "The 'Cron-Job Demo' job will be triggered when we
  satisfy the additional dependency on the branch name.".strip_heredoc, type: :feature do

  before :each do
    setup_signin_waitforcommits
  end

  it :works do

    expect(page).not_to have_selector(
      ".job[data-name='Cron-Job Demo']")

    expect(page).not_to have_selector(
      ".commits .commit .branches .branch", text: 'cron-test')

    sleep 60

    expect(page).not_to have_selector(".job[data-name='Cron-Job Demo']")

    expect(Helpers::DemoRepo.create_new_branch('cron-test')) \
      .to pass_execution

    wait_until do
      page.has_selector?(".commits .commit .branches .branch", text: 'cron-test')
    end

    wait_until 90 do
      page.has_selector?(".job[data-name='Cron-Job Demo']")
    end
  end
end
