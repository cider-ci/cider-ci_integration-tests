require 'spec_helper'

describe 'The executor version diverges from the server version', type: :feature do

  before :all do
    Helpers::Misc.reset_and_configure
  end

  def set_mismatch_version
    Helpers::DemoExecutor.eval_clj <<-CLJ.strip_heredoc
      (ns cider-ci.self)
      (def VERSION "Cider-CI 0.0.0-P+T")
    CLJ
  end

  describe 'when setting a different version ' do
    it 'a "Version Mismatch" executor_issue shows in several places' \
      'and not trial will be dispatched to the executor' do
      sign_in_as 'admin'
      click_on 'Administration'
      click_on 'Executors'
      wait_until do
        all("tr.executor").count > 0
      end
      expect(page).not_to have_selector(".executor-issue-warning")
      set_mismatch_version
      wait_until do
        all(".executor-issue-warning").count > 0
      end
      first('tr.executor a').click
      expect(page).to have_content ("Version Mismatch")

      run_job_on_last_commit 'JSON Demo'

      sleep 30

      # the job is still pending
      expect(
        all(".job[data-name='JSON Demo'][data-state='pending']")
      ).to be_present


    end
  end
end
