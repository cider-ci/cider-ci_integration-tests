module Helpers
  module DemoRepo

    class << self

      def system_path
        Pathname(
          "#{Dir.pwd}/../demo-project-bash/"
        ).cleanpath.to_s
      end

      def exec! cmd
        Dir.chdir system_path do
          Helpers::System.exec! <<-CMD.strip_heredoc
            #!/bin/env/bash
            set -eux
            #{cmd}
          CMD
        end
      end

      def tree_id
        exec! <<-CMD.strip_heredoc
          git log -n 1 --pretty=%T
        CMD
      end

      def remove_file path
        Dir.chdir system_path do
          if File.exists? path
            File.delete path
          end
        end
      end

      def git_url
        Pathname(
          "#{Dir.pwd}/../demo-project-bash/"
        ).cleanpath.to_s
      end

      def reset_branches
        exec! <<-CMD.strip_heredoc
          git checkout #{TEST_COMMIT_ID}
          git for-each-ref --format '%(refname:short)' refs/heads | xargs git branch -D
          git checkout -b #{TEST_BRANCH}
        CMD
      end

      def reset!
        reset_branches
      end

      def setup_demo_repo
        reset_branches
        raise 'TODO replace ConfigrationManagement'
        Helpers::ConfigurationManagement.invoke_ruby \
          "Repository.find_or_initialize_by(name: 'Demo Project') " \
          '.update! ' \
          "git_url: '#{git_url}', "\
          'remote_fetch_interval: "1 Second", ' \
          'branch_trigger_max_commit_age: "100 years", '\
          'public_view_permission: true'
        git_update_server_info
      end

      def git_update_server_info
        exec! <<-CMD.strip_heredoc
          git update-server-info
        CMD
      end

      def create_a_new_branch_and_commit_cmd(branch_name, message)
        'cd ../demo-project-bash && git stash ' \
          "&& git reset --hard && git checkout #{TEST_BRANCH}" \
          "&& git checkout -b #{branch_name} " \
          "&& echo '#{message}' >> BLAH.md " \
          '&& git add . ' \
          "&& git commit -a -m '#{message}' " \
          '&& git update-server-info'
      end

      def create_new_branch(branch_name)
        'cd ../demo-project-bash && git stash ' \
          "&& git reset --hard && git checkout #{TEST_BRANCH}" \
          "&& git branch #{branch_name} " \
          '&& git update-server-info'
      end

      def delete_branch_cmd(branch_name)
        'cd ../demo-project-bash; '\
          'git stash; ' \
          'git reset --hard; ' \
          "git checkout #{TEST_BRANCH};" \
          "git branch -D '#{branch_name}'; " \
          'git update-server-info'
      end
    end
  end
end
