require 'spec_helper'

describe 'Dispatching and executing in ', type: :feature do
  before :each do
    setup_signin_waitforcommits
  end

  describe 'push mode (default)' do
    it 'processes a passing job with passed' do
      Helpers::DemoExecutor.configure_demo_executor
      expect(Helpers::ConfigurationManagement.invoke_ruby(
               'Executor.first.base_url')).not_to(be_blank)
      run_job_on_last_commit 'Ports Demo'
      wait_for_job_state 'Ports Demo', 'passed'
    end
  end

  describe 'pull mode (default)' do
    it 'processes a passing job with passed' do
      Helpers::DemoExecutor.configure_demo_executor
      Helpers::ConfigurationManagement.invoke_ruby(
        'Executor.first.update_attributes! base_url: nil')
      expect(Helpers::ConfigurationManagement.invoke_ruby(
               'Executor.first.base_url')).to(be_blank)
      run_job_on_last_commit 'JSON Demo'
      wait_for_job_state 'JSON Demo', 'passed'
    end
  end
end
