require 'json_roa/client'
require 'nrepl'
require 'timeout'

module Helpers
  module Misc
    extend self

    def wait_until(wait_time = 60, &block)
      begin
        Timeout.timeout(wait_time) do
          until value = block.call
            sleep(1)
          end
          value
        end
      rescue Timeout::Error => e
        fail Timeout::Error.new(block.source)
      end
    end

    def click_on_first(locator, options = {})
      wait_until(3){first(:link_or_button, locator, options)}
      first(:link_or_button, locator, options).click
    end

    def path_to_job(id)
      "/cider-ci/ui/workspace/jobs/#{id}"
    end

    def reset_and_configure
      Helpers::ConfigurationManagement.invoke_ruby 'PgTasks.truncate_tables() && "OK"'
      Helpers::Users.create_users
      Helpers::DemoRepo.setup_demo_repo
      Helpers::DemoExecutor.define_executor
    end

    def setup_signin_waitforcommits
      reset_and_configure
      sign_in_as 'admin'
      within '#nav' do
        first("li.commits a").click
      end
      wait_until(10){ all('.tree-commits .tree-commit').count > 0 }
    end

    def api_click_on_relation_method(rel_name, method_name)
      sleep 0.5
      find('tr.relation-row .rel-name', text: /^\s*#{rel_name}\s*$/) \
        .find(:xpath, '..').find('a', text: method_name).click
    end

    def api_continue_with_url_parameters(text)
      find('textarea#url-parameters-input').set(text)
      click_on('Continue')
    end

    def api_click_on_first_collection_item_method(method_name)
      find('#collection').first('tr.relation-row') \
        .find('a', text: method_name).click
    end

    def run_job_on_last_commit(job_name)
      click_on_first 'Commits'
      wait_until(45){ all('.tree-commits .tree-commit').count > 0 }
      first('.tree-commits .tree-commit a.tree-id').click
      click_on_first 'Run'
      find(".runnable-job[data-name='#{job_name}']")
        .find('a,button', text: 'Run').click
    end

    def wait_for_job_state(job_name, state,
      options = { wait_time:  60, forbidden_terminal_states: %w(passed failed aborted) - [state] })
      wait_until options[:wait_time] do
        all(".job[data-name='#{job_name}'][data-state='#{state}']").present?
      end
      expect(options[:forbidden_terminal_states]).not_to include first(".job[data-name='#{job_name}']")['data-state']
    end

    def api_connection
      base_url = "#{Capybara.app_host}/cider-ci/api/"
      ::JSON_ROA::Client.connect base_url do |conn|
        conn.basic_auth('admin', 'secret')
        conn.ssl.verify = false
      end
    end

    def eval_clj_via_nrepl(port, code)
      repl = Nrepl::Repl.connect(Integer(port))
      res = repl.eval code
      res.select{|r| r["ex"].present?}.map{|err| raise err["ex"]}
    end

  end
end
