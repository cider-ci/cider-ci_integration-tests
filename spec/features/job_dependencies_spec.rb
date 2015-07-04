# # Testing Triggers and Dependency declaration of Jobs
#
# The jobs we use here are declared in the [`.cider-ci.yml`
# dotfile](https://github.com/cider-ci/cider-ci_demo-project-bash/blob/master/.cider-ci.yml)
# of the [Bash Demo Project for
# Cider-CI](https://github.com/cider-ci/cider-ci_demo-project-bash).
#
require 'spec_helper'

describe 'Jobs - Dependencies and Triggers, ', type: :feature do
  let :prerequisite_name do
    'Jobs - Dependencies and Triggers - Prerequisite'
  end

  let :dependent_name do
    'Jobs - Dependencies and Triggers - Dependent'
  end

  before :all do
    setup_signin_waitforcommits
  end

  after :all do
    `#{Helpers::DemoRepo.delete_branch_cmd('trigger-prerequisite')}`
  end

  before :each do
    `#{Helpers::DemoRepo.delete_branch_cmd('trigger-prerequisite')}`
    Helpers::ConfigurationManagement.invoke_sql 'DELETE FROM jobs'
    sign_in_as 'adam'
    # set_aggressive_reloading
    click_on 'Commits'
  end

  describe 'the prerequisite job ' do
    it 'is created once a branch matching /trigger-prerequisite/ has been created' do
      expect(Helpers::DemoRepo.create_new_branch('trigger-prerequisite')) \
        .to pass_execution

      wait_until { all('#commits-table tbody tr').count > 0 }

      wait_until { all(".job[data-name='#{prerequisite_name}']").count > 0 }

      wait_until do
        all(".job[data-name='#{prerequisite_name}'][data-state='passed']").present?
      end
    end
  end

  describe 'the dependent job' do
    it 'is created once the prerequisite has passed' do
      first('a.run-a-job').click

      expect(all(".runnable-job[data-name='#{dependent_name}']")).to be_empty

      find(".runnable-job[data-name='#{prerequisite_name}']")
        .find('a,button', text: 'Run').click

      expect(all(".job[data-name='#{prerequisite_name}']")).not_to be_empty

      expect(all(".job[data-name='#{dependent_name}']")).to be_empty

      wait_until do
        all(".job[data-name='#{prerequisite_name}'][data-state='passed']") \
          .present?
      end

      wait_until { all(".job[data-name='#{dependent_name}']").present? }

      wait_until do
        all(".job[data-name='#{dependent_name}'][data-state='passed']") \
          .present?
      end
    end
  end
end
