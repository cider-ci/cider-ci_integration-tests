module Helpers
  module DemoRepo
    class << self
      def git_url
        "#{Dir.pwd}/../demo-project-bash/"
      end

      def setup_demo_repo
        Helpers::ConfigurationManagement.invoke_ruby \
          "Repository.find_or_initialize_by(name: 'Demo Project') " \
          '.update_attributes! ' \
          "git_url: '#{git_url}', "\
          'git_fetch_and_update_interval: 1, ' \
          'public_view_permission: true'
        git_update_server_info
      end

      def git_update_server_info
        `cd ../demo-project-bash && git update-server-info`
        fail 'git_update_server_info' unless $?.exitstatus == 0
      end

      def create_a_new_branch_and_commit_cmd(branch_name, message)
        'cd ../demo-project-bash && git stash ' \
          '&& git reset --hard && git checkout master' \
          "&& git checkout -b #{branch_name} " \
          "&& echo '#{message}' >> BLAH.md " \
          '&& git add . ' \
          "&& git commit -a -m '#{message}' " \
          '&& git update-server-info'
      end

      def create_new_branch(branch_name)
        'cd ../demo-project-bash && git stash ' \
          '&& git reset --hard && git checkout master' \
          "&& git branch #{branch_name} " \
          '&& git update-server-info'
      end

      def delete_branch_cmd(branch_name)
        'cd ../demo-project-bash; '\
          'git stash; ' \
          'git reset --hard; ' \
          'git checkout master;' \
          "git branch -D '#{branch_name}'; " \
          'git update-server-info'
      end
    end
  end
end
