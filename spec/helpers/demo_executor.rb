module Helpers
  module DemoExecutor
    class << self
      def configure_demo_executor
        Helpers::ConfigurationManagement.invoke_ruby \
          'Executor.find_or_initialize_by(name: "DemoExecutor")' \
          '.update_attributes!(base_url: "http://localhost:8883") '
      end
    end
  end
end
