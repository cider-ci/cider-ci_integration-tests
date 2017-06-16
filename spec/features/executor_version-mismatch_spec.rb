require 'spec_helper'

describe 'The executor version diverges from the server version', type: :feature do

  before :all do
    Helpers::Misc.reset_and_configure
  end

  def set_mismatch_version
    Helpers::DemoExecutor.eval_clj <<-CLJ.strip_heredoc
      (ns cider-ci.utils.self)
      (defn version [] "0.0.0-P+T")
    CLJ
  end

  describe 'when setting a different version ' do
    it 'the (differing) version is shown as a property ' \
      'and not trial will be dispatched to the executor' do
      sign_in_as 'admin'

      visit '/cider-ci/executors/'
      wait_until(10){ first("a", text: 'Test-Executor')}
      first("a", text: 'Test-Executor').click
      wait_until 10 do
        visit current_path
        wait_until(10){first("#version")}
      end

      version = YAML.load(first("#version .value").text.strip)

      set_mismatch_version

      # wait until the version diverges

      wait_until 10 do
        visit current_path
        wait_until(10){first("#version")}
        version != YAML.load(first("#version .value").text.strip)
      end

#
#      wait_until do
#        all(".executor-issue-warning").count > 0
#      end
#      first('tr.executor a').click
#      expect(page).to have_content ("Version Mismatch")
#
      run_job_on_last_commit 'JSON Demo'

      sleep 30

      # the job is still pending
      expect(
        all(".job[data-name='JSON Demo'][data-state='pending']")
      ).to be_present


    end
  end
end
