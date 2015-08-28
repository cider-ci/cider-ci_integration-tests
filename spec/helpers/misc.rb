require 'timeout'
require 'json_roa/client'

module Helpers
  module Misc
    def wait_until(wait_time = 60)
      Timeout.timeout(wait_time) do
        sleep(0.1) until value = yield
        value
      end
    end

    def click_on_first(locator, options = {})
      first(:link_or_button, locator, options).click
    end

    def path_to_job(id)
      "/cider-ci/ui/workspace/jobs/#{id}"
    end

    def setup_signin_waitforcommits
      Helpers::ConfigurationManagement.invoke_ruby 'PgTasks.truncate_tables()'
      Helpers::Users.create_users
      Helpers::DemoRepo.setup_demo_repo
      Helpers::DemoExecutor.configure_demo_executor

      sign_in_as 'adam'
      wait_until { all('#commits-table tbody tr').count > 0 }
    end

    def api_click_on_relation_method(rel_name, method_name)
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
      click_on_first 'Workspace'
      wait_until { all('a.show-commit').count > 0 }
      click_on_first 'Run'
      find(".runnable-job[data-name='#{job_name}']")
        .find('a,button', text: 'Run').click
    end

    def wait_for_job_state(job_name, state, options = { wait_time:  60 })
      wait_until options[:wait_time] do
        all(".job[data-name='#{job_name}'][data-state='#{state}']").present?
      end
    end

    def api_connection
      base_url = "#{Capybara.app_host}/cider-ci/api"
      ::JSON_ROA::Client.connect base_url  do |conn|
        conn.basic_auth('adam', 'password')
        conn.ssl.verify = false
      end
    end
  end
end
