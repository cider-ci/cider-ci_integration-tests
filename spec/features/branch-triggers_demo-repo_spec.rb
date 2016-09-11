require 'spec_helper'

describe " Triggering jobs via branch updates with respect of
  matches in the project and repository.  ".strip_heredoc, type: :feature do

  let :prerequisite_name do
    'Jobs - Dependencies and Triggers - Prerequisite'
  end

  before :each do
    setup_signin_waitforcommits
  end

  describe "Trigger defined on the repository
  with unmodified repository match".strip_heredoc do

    it "the job gets automatically created
    when an appropriate branch update is pushed".strip_heredoc do
      expect(Helpers::DemoRepo.create_new_branch('trigger-prerequisite')) \
        .to pass_execution

      wait_until { all(".job[data-name='#{prerequisite_name}']").count > 0 }

    end
  end

  describe "Trigger defined on the repository
  when the repository include match is set not to match
  the trigger branch ".strip_heredoc do

    it "the job will not be created automatically
    when an appropriate branch update is pushed".strip_heredoc do

      click_on 'Projects'
      wait_until { page.has_content? 'Demo Project'}
      click_on "Demo Project"
      click_on "Edit"
      find('input#branch_trigger_include_match').set 'some non existing branch'
      find("[type='submit']").click
      first("a",text: "Workspace").click
      expect(Helpers::DemoRepo.create_new_branch('trigger-prerequisite')) \
        .to pass_execution

      sleep 30

      expect(page).not_to have_selector(".job[data-name='#{prerequisite_name}']")


    end

  end

end

