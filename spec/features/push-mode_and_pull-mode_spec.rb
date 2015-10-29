require 'spec_helper'
require 'shared/push_and_pull'

shared_examples :passes_the_json_demo  do
  context 'The JSON Demo' do
    it 'passes when being run' do
      run_job_on_last_commit 'JSON Demo'
      wait_for_job_state 'JSON Demo', 'passed'
    end
  end
end

describe 'Dispatching and running in ', type: :feature do
  include_context :run_in_push_and_pull_mode, :passes_the_json_demo
end
