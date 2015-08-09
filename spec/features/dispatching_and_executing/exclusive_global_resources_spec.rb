require 'spec_helper'
require 'shared/push_and_pull'

shared_examples :passes_the_exclusive_global_resources_demo  do
  context 'The Exclusive Global Resources Demo' do
    it 'passes when being run' do
      expect(Integer(Helpers::ConfigurationManagement.invoke_ruby(
        'Executor.first.max_load'))).to be > 1
      run_job_on_last_commit 'Exclusive Global Resources Demo'
      wait_for_job_state 'Exclusive Global Resources Demo', 'passed'
    end
  end
end

describe 'Dispatching and running in ', type: :feature do
  include_context :run_in_push_and_pull_mode,
                  :passes_the_exclusive_global_resources_demo
end
