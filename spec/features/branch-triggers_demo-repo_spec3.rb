require 'spec_helper'

describe " Triggering jobs via branch updates with respect of
  matches in the project and repository.  ".strip_heredoc, type: :feature do

  let :prerequisite_name do
    'Jobs - Dependencies and Triggers - Prerequisite'
  end

  before :each do
    setup_signin_waitforcommits
  end

  describe "A trigger defined on the repository,
  when the repository include match is set not to match,
  and the max_commit_age is very old.".strip_heredoc do

    before :each do
      click_on 'Projects'
      wait_until { page.has_content? 'Demo Project'}
      click_on "Demo Project"
      click_on "Edit"
      find('input#branch_trigger_include_match').set 'some non existing branch'
      find('input#branch_trigger_max_commit_age').set '100 Years'
      find("[type='submit']").click
      wait_until(10) { first(".modal") }
      wait_until(10) { ! first(".modal") }
    end

    it "the job will not be created automatically
    when an appropriate branch update is pushed".strip_heredoc do
      expect(Helpers::DemoRepo.create_new_branch('trigger-prerequisite')) \
        .to pass_execution
      first("a",text: "Workspace").click
      sleep 30
      expect(page).not_to have_selector(".job[data-name='#{prerequisite_name}']")
    end
  end
end

