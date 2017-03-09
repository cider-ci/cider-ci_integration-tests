require 'spec_helper'

describe "Cron demo from the demo repo" , type: :feature do

  before :each do
    setup_signin_waitforcommits
  end

  describe "Demo repository with cron_trigger_enabled" do

    before :each do
      click_on 'Projects'
      wait_until { page.has_content? 'Demo Project'}
      click_on "Demo Project"
      click_on "Edit"
      find('input#cron_trigger_enabled').click
      find("[type='submit']").click
      wait_until(10) { first(".modal") }
      wait_until(10) { ! first(".modal") }
    end


    it "The 'Cron-Job Demo' job will be triggered when we
      satisfy the additional dependency on the branch name.".strip_heredoc do

      click_on_first "Workspace"

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
end
