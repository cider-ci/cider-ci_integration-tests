require 'active_support'
require 'yaml'

module Helpers
  module DemoExecutor
    class << self


      CONFIG_FILE = '../executor/config.yml'

      ID = '88438012-ee85-418e-8988-bbd3f5ca12d3'
      NAME= 'Test-Executor'
      TOKEN= 'TestExecutor1234'

      def amend_config cfg
        existing_config = YAML.load_file(CONFIG_FILE).with_indifferent_access
        IO.write CONFIG_FILE, existing_config.deep_merge(cfg).as_json.to_yaml
      end

      def define_executor
        conn = Helpers::SystemAdmin.connection
        create_response = conn.put "/cider-ci/executors/#{ID}",
          {name: NAME, token: TOKEN}.to_json
        raise 'failed to define_executor' \
          unless create_response.status.between?(200,299)
      end

      def eval_clj code
        port = Integer( ENV['EXECUTOR_NREPL_PORT'].presence || 7883)
        Helpers::Misc.eval_clj_via_nrepl port, code
      end

      def set_accepted_repositories(repos)
        amend_config({accepted_repositories: repos})
      end

      def reset_accepted_repositories
        amend_config({accepted_repositories: ['^.*$']})
      end

      def reset_config
        reset_accepted_repositories
      end

    end
  end
end
