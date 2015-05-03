# # Testing Triggers and Dependency declaration of Jobs
#
# The jobs we use here are declared in the [`.cider-ci.yml`
# dotfile](https://github.com/cider-ci/cider-ci_demo-project-bash/blob/master/.cider-ci.yml)
# of the [Bash Demo Project for
# Cider-CI](https://github.com/cider-ci/cider-ci_demo-project-bash).
#
require 'spec_helper'

describe 'Dependencies and Triggers, ', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end

  after :all do
    Helpers::DemoRepo.delete_branch_cmd('trigger-prerequisite')
  end

  before :each do
    Helpers::ConfigurationManagement.invoke_sql 'DELETE FROM jobs'
    sign_in_as 'adam'
    # set_aggressive_reloading
    click_on 'Commits'
  end

  describe 'the "Dependencies and Triggers Prerequisite" job ' do
    it 'is created once a branch matching /trigger-test/ is created' do
      expect(Helpers::DemoRepo.create_new_branch('trigger-prerequisite')) \
        .to pass_execution

      wait_until { all('#commits-table tbody tr').count > 0 }

      wait_until { first(".job[data-name='Dependencies and Triggers Prerequisite']") }

      wait_until do
        all(".job[data-name='Dependencies and Triggers Prerequisite'][data-state='passed']").present?
      end
    end
  end

  describe 'the "Dependencies and Triggers Depends" jobs' do
    it 'is created once the "Chain-Prerequisite-Demo" has passed' do
      first('a.run-a-job').click

      expect(all(".runnable-job[data-name='Dependencies and Triggers Depends']")).to be_empty

      find(".runnable-job[data-name='Dependencies and Triggers Prerequisite']")
        .find('a,button', text: 'Run').click

      expect(all(".job[data-name='Dependencies and Triggers Prerequisite']")).not_to be_empty

      expect(all(".job[data-name='Dependencies and Triggers Depends']")).to be_empty

      wait_until do
        all(".job[data-name='Dependencies and Triggers Prerequisite'][data-state='passed']") \
          .present?
      end

      wait_until { all(".job[data-name='Dependencies and Triggers Depends']").present? }

      wait_until do
        all(".job[data-name='Dependencies and Triggers Depends'][data-state='passed']") \
          .present?
      end
    end
  end
end
