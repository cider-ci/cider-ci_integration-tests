module Helpers
  module DemoRepo
    class << self
      def setup_demo_repo
        Helpers::ConfigurationManagement.invoke_ruby \
          "Repository.find_or_initialize_by(name: 'DemoRepoBash') " \
          '.update_attributes! ' \
          "origin_uri: '#{Capybara.app_host}/cider-ci/demo-project-bash/'," \
          'git_fetch_and_update_interval: 5, ' \
          'public_view_permission: true'
        git_update_server_info
      end

      def git_update_server_info
        `cd ../demo-project-bash && git update-server-info`
        fail 'git update-server-info' unless $?.exitstatus == 0
      end

      def create_a_new_branch_and_commit_cmd(branch_name, message)
        'cd ../demo-project-bash && git stash ' \
          '&& git reset --hard && git checkout v3' \
          "&& git checkout -b #{branch_name} " \
          "&& echo '#{message}' >> BLAH.md " \
          '&& git add . ' \
          "&& git commit -a -m '#{message}' " \
          '&& git update-server-info'
      end

      def create_new_branch(branch_name)
        'cd ../demo-project-bash && git stash ' \
          '&& git reset --hard && git checkout v3' \
          "&& git branch #{branch_name} " \
          '&& git update-server-info'
      end

      def delete_branch_cmd(branch_name)
        'cd ../demo-project-bash && git stash ' \
          '&& git reset --hard ' \
          '&& git checkout v3' \
          "&& git branch -D #{branch_name} " \
          '&& git update-server-info'
      end
    end
  end
end
