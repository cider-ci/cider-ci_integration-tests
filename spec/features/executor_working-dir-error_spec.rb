require 'spec_helper'

describe 'prepare-and-create-working-dir with throwing exception', type: :feature do

  before :each do
    Helpers::Misc.reset_and_configure
  end

  def executor_throws_when_creating_the_working_dir
    Helpers::DemoExecutor.eval_clj <<-CLJ.strip_heredoc
      (ns cider-ci.executor.git)
      (defn prepare-and-create-working-dir [params]
        (throw (ex-info "Simulating exception during prepare-and-create-working-dir." {})))
    CLJ
  end

  it 'leaves a trial in defective state' do
    sign_in_as 'admin'
    executor_throws_when_creating_the_working_dir
    run_job_on_last_commit 'JSON Demo'
    wait_for_job_state 'JSON Demo', 'defective'
  end

end
