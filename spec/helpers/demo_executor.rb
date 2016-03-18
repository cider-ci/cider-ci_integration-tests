module Helpers
  module DemoExecutor
    class << self

      ACCEPTED_REPOSITORIES_FILE = '../executor/config/accepted-repositories.yml'

      def set_accepted_repositories(repos)
        File.open(ACCEPTED_REPOSITORIES_FILE, 'w') do |file|
          file.write repos.to_yaml
        end
      end

      def cleanup
        require 'fileutils'
        FileUtils.rm(ACCEPTED_REPOSITORIES_FILE) rescue nil
      end

      def eval_clj code
        port = Integer( ENV['EXECUTOR_NREPL_PORT'].presence || 7883)
        Helpers::Misc.eval_clj_via_nrepl port, code
      end

    end
  end
end
