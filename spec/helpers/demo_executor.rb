require 'active_support'
require 'yaml'

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


      CONFIG_FILE = '../executor/config/config.yml'
      def amend_config cfg
        existing_config = YAML.load_file(CONFIG_FILE).with_indifferent_access
        IO.write CONFIG_FILE, existing_config.deep_merge(cfg).as_json.to_yaml
      end

    end
  end
end
