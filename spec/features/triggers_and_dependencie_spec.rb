# # Testing Triggers and Dependency declaration of Jobs
#
# The jobs we use here are declared in the [`.cider-ci.yml`
# dotfile](https://github.com/cider-ci/cider-ci_demo-project-bash/blob/master/.cider-ci.yml)
# of the [Bash Demo Project for
# Cider-CI](https://github.com/cider-ci/cider-ci_demo-project-bash).
#
require 'spec_helper'

describe 'job triggers, ', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end

  after :all do
    expect(Helpers::DemoRepo.delete_branch_cmd(
             'trigger-test')).to pass_execution
  end

  before :each do
    Helpers::ConfigurationManagement.invoke_sql 'DELETE FROM jobs'
    sign_in_as 'adam'
    # set_aggressive_reloading
    click_on 'Commits'
  end

  describe 'the "Trigger-Demo" job ' do
    it 'is created once a branch matching /trigger-test/ is created' do
      expect(Helpers::DemoRepo.create_new_branch('trigger-test')) \
        .to pass_execution

      wait_until { all('#commits-table tbody tr').count > 0 }

      wait_until { first(".job[data-name='Trigger-Demo']") }

      wait_until do
        all(".job[data-name='Trigger-Demo'][data-state='passed']").present?
      end
    end
  end

  describe 'the "Chain-Dependent-Demo" jobs' do
    it 'is created once the "Chain-Prerequisite-Demo" has passed' do
      first('a.run-a-job').click

      expect(all(".runnable-job[data-name='Chain-Dependent-Demo']")).to be_empty

      find(".runnable-job[data-name='Chain-Prerequisite-Demo']")
        .find('a,button', text: 'Run').click

      expect(all(".job[data-name='Chain-Prerequisite-Demo']")).not_to be_empty

      expect(all(".job[data-name='Chain-Dependent-Demo']")).to be_empty

      wait_until do
        all(".job[data-name='Chain-Prerequisite-Demo'][data-state='passed']") \
          .present?
      end

      wait_until { all(".job[data-name='Chain-Dependent-Demo']").present? }

      wait_until do
        all(".job[data-name='Chain-Dependent-Demo'][data-state='passed']") \
          .present?
      end
    end
  end
end
