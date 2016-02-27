module Helpers
  module DemoExecutor
    class << self
      ACCEPTED_REPOSITORIES_FILE = '../executor/config/accepted-repositories.yml'
      def configure_demo_executor
        port = Integer(ENV['EXECUTOR_HTTP_PORT'].present? &&
                       ENV['EXECUTOR_HTTP_PORT'] || '8883')
        Helpers::ConfigurationManagement.invoke_ruby <<-RUBY.strip_heredoc
          Executor.find_or_initialize_by(name: "DemoExecutor",
              id: "ENV['EXECUTOR_ID']")
            .update_attributes!(base_url: 'http://localhost:#{port}' ,
              upload_tree_attachments: true)"
          RUBY
      end

      def set_accepted_repositories(repos)
        File.open(ACCEPTED_REPOSITORIES_FILE, 'w') do |file|
          file.write repos.to_yaml
        end
      end

      def cleanup
        require 'fileutils'
        FileUtils.rm(ACCEPTED_REPOSITORIES_FILE) rescue nil
      end
    end
  end
end
