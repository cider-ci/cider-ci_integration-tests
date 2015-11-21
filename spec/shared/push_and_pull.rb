shared_context :executor_push_mode do
  before :each do
    Helpers::DemoExecutor.configure_demo_executor
    fail 'Executor is not in push mode!' unless \
      JSON.parse(Helpers::ConfigurationManagement \
        .invoke_ruby('Executor.first.base_url')) \
        .with_indifferent_access[:result].present?
  end
end

shared_context :executor_pull_mode do
  before :each do
    Helpers::DemoExecutor.configure_demo_executor
    Helpers::ConfigurationManagement.invoke_ruby(
      'Executor.first.update_attributes! base_url: nil')
    fail 'Executor is not in pull mode!' unless \
      JSON.parse(Helpers::ConfigurationManagement \
        .invoke_ruby('Executor.first.base_url')) \
        .with_indifferent_access[:result].blank?
  end
end

shared_context :run_in_push_and_pull_mode do |example|
  before :each do
    setup_signin_waitforcommits
  end

  describe 'pull mode' do
    include_context :executor_pull_mode
    include_examples example
  end

  describe 'push mode' do
    include_context :executor_push_mode
    include_examples example
  end
end

shared_context :run_in_push_mode do |example|
  before :each do
    setup_signin_waitforcommits
  end

  describe 'push mode' do
    include_context :executor_push_mode
    include_examples example
  end

end
