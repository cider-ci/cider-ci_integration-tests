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
    sign_in_as 'admin'
  end

  let :submodule_ref do
    TEST_COMMIT_ID = Helpers::System.exec!("
      #!/usr/bin/env bash
      cd ../demo-project-bash/
      git submodule status submodule") \
        .strip.split(/\s+/).first.gsub(/^-|\+|U/,"")
  end

  describe 'the dependent job' do
    it 'is created once the prerequisite in the submodule has passed' do
      click_on_first 'Workspace'
      find('select#depth').select('Any depth')
      find('input#git_ref').set(submodule_ref)
      click_on('Filter')
      first('a.run-a-job').click
      find(".runnable-job[data-name='#{prerequisite_name}']")
        .find('a,button', text: 'Run').click

      # the dependent will run automatically on the current branch
      click_on_first 'Workspace'
      find('input#git_ref').set('')
      click_on('Filter')
      wait_until do
        all(".job[data-name='#{dependent_name}'][data-state='passed']") \
          .present?
      end
    end
  end
end
