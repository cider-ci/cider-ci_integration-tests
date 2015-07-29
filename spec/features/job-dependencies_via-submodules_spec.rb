require 'spec_helper'

describe 'Jobs - Dependencies and Triggers, ', type: :feature do
  let :prerequisite_name do
    'Jobs - Dependencies and Triggers - Prerequisite'
  end

  let :dependent_name do
    'Jobs - Dependencies and Triggers - Submodule-Dependent'
  end

  before :all do
    setup_signin_waitforcommits
  end

  before :each do
    Helpers::ConfigurationManagement.invoke_sql 'DELETE FROM jobs'
    sign_in_as 'adam'
  end

  describe 'the dependent job' do
    it 'is created once the prerequisite in the submodule has passed' do

      click_on 'Commits'
      first('a.run-a-job').click
      expect(page).not_to have_content dependent_name

      click_on('Commits')
      find('select#depth').select('Any depth and orphans')
      click_on('Filter')
      click_on('3b6951')
      first('a.run-a-job').click
      find(".runnable-job[data-name='#{prerequisite_name}']")
        .find('a,button', text: 'Run').click

      # the dependent will run automatically on the current branch
      click_on('Commits')
      wait_until do
        all(".job[data-name='#{dependent_name}'][data-state='passed']") \
          .present?
      end
    end
  end
end
