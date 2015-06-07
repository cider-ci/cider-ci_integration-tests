module Helpers
  module DemoExecutor
    class << self
      def configure_demo_executor
        port = Integer(ENV['EXECUTOR_HTTP_PORT'].present? && 
                       ENV['EXECUTOR_HTTP_PORT'] || '8883')
        Helpers::ConfigurationManagement.invoke_ruby \
          'Executor.find_or_initialize_by(name: "DemoExecutor")' \
          ".update_attributes!(base_url: 'http://localhost:#{port}') "
      end
    end
  end
end
