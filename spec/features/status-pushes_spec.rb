require 'spec_helper'
require 'yaml'
require 'fileutils'

describe "Sending job statuses to a GitHub compatible API endpoint.",
  type: :feature do

  before :each do
    Helpers::DemoRepo.reset!
    Helpers::ConfigurationManagement.invoke_ruby 'PgTasks.truncate_tables() && "OK"'
    Helpers::Users.create_users

  end

  let :github_api_mock_port do
    ENV['GITHUB_API_MOCK_PORT'].presence  \
      || fail("GITHUB_API_MOCK_PORT is not set")
  end

  it "The project UI shows the proper information and " \
    "the API mock writes the status and appropriate data into a file" do

      config = (YAML.load_file('../config/config.yml') rescue {}).with_indifferent_access
      config[:status_pushes_name_prefix] = nil
      IO.write('../config/config.yml', config.to_h.to_yaml)

      ### prepare with disabled status-pushes #################################

      sign_in_as 'admin'
      visit '/'
      click_on 'Projects'
      click_on 'Add a new project'

      find('input#git_url').set Helpers::DemoRepo.system_path
      find('input#name').set 'Test Project'
      find("input.send_status_notifications").set(false)
      find('input#remote_api_token').set "test-token"
      find('input#remote_api_endpoint').set "http://localhost:#{github_api_mock_port}"
      find('input#remote_api_namespace').set "test-org"
      find('input#remote_api_name').set "test-repo"
      find('select#remote_api_type').select('github')
      find('input#remote_fetch_interval').set "3 Seconds"
      find("[type='submit']").click

      wait_until 5 do
        first("table.table-project td.status-pushes", text: 'disabled')
      end


      ### enabled but with out token ##########################################

      click_on 'Edit'
      find("input.send_status_notifications").set(true)
      find('input#remote_api_token').set " "
      find("[type='submit']").click
      wait_until 5 do
        first("table.table-project td.status-pushes.danger", text: 'unaccessible')
      end


      ### now enalbe it but set a illegal token ###############################
      click_on 'Edit'
      find("input.send_status_notifications").set(true)
      find('input#remote_api_token').set "faux-token"
      find("[type='submit']").click

      wait_until 5 do
        first("table.table-project td.status-pushes", text: 'unused')
      end

      ### run a job ###########################################################

      wait_until{ first("table.table-project td.text-center.branches.success") }

      FileUtils.rm ['tmp/last-status-post.yml'], force: true

      run_job_on_last_commit 'Introduction Demo and Example Job'
      wait_for_job_state 'Introduction Demo and Example Job', 'passed'


      ### now, since the token is wrong we should see an error ################

      click_on_first "Projects"
      click_on_first "Test Project"
      wait_until 5 do
        first("table.table-project td.status-pushes.danger", text: 'error')
      end


      ### fix the token ########################################################

      click_on 'Edit'
      find('input#remote_api_token').set "test-token"
      find("[type='submit']").click

      ### this should change the status to success ############################

      wait_until 5 do
        first("table.table-project td.status-pushes.success",
              text: 'a few seconds ago')
      end

      ### check the proper data has been sent ##################################

      wait_until 30 do
        File.exist?('tmp/last-status-post.yml') &&
          (YAML.load_file('tmp/last-status-post.yml')
           .with_indifferent_access[:body][:state] == 'success')
      end


      commit_sha = Helpers::DemoRepo.exec! 'git log -n 1 --format=%H'

      written_data = YAML.load_file('tmp/last-status-post.yml').with_indifferent_access
      expect(written_data[:auth_token]).to be== 'test-token'
      expect(written_data[:sha]).to be== commit_sha
      expect(written_data[:body][:state]).to be== 'success'
      expect(written_data[:body][:target_url]).to be_present
      expect(written_data[:body][:description]).to be_present
      expect(written_data[:body][:context]).to be_present


      ### push statuses manually ##############################################

      # first wait until the pushed status happen some while ago
      last_posted_at_before = Time.parse(first("table td.status-pushes")['data-last-posted-at'])
      first("button.push-statuses").click
      wait_until 5 do
        last_posted_at_before \
          <  Time.parse(first("table td.status-pushes")['data-last-posted-at'])
      end


      ### configurable status name prefix ######################################

      written_data = YAML.load_file('tmp/last-status-post.yml').with_indifferent_access
      # check the various config files if this fails unexpected

      expect(written_data[:body][:context]).to match 'Cider-CI@localhost'

      config = (YAML.load_file('../config/config.yml') rescue {}).with_indifferent_access
      config[:status_pushes_name_prefix] = "TestPrefix"
      IO.write('../config/config.yml', config.to_h.to_yaml)
      sleep 5 # load config
      last_posted_at_before = Time.parse(first("table td.status-pushes")['data-last-posted-at'])
      first("button.push-statuses").click
      wait_until 5 do
        last_posted_at_before \
          <  Time.parse(first("table td.status-pushes")['data-last-posted-at'])
      end
      written_data = YAML.load_file('tmp/last-status-post.yml').with_indifferent_access
      expect(written_data[:body][:context]).to match 'TestPrefix'
      config[:status_pushes_name_prefix] = nil
      IO.write('../config/config.yml', config.to_h.to_yaml)

      ### check for success status push for new amended commit ################

      last_posted_at_before = Time.parse(first("table td.status-pushes")['data-last-posted-at'])

      FileUtils.rm ['tmp/last-status-post.yml'], force: true

      Helpers::DemoRepo.exec! 'git commit --allow-empty -m "Some new commit with same tree_id" '
      Helpers::DemoRepo.git_update_server_info

      click_on_first "Projects"
      click_on_first "Test Project"
      first("table td.fetch-and-update").first("a.fetch-now, button.fetch-now").click
      sleep 1
      wait_until do
        first("table td.fetch-and-update[data-state='ok']")
      end
      click_on_first("Workspace")
      wait_until do
        page.has_content? "Some new commit"
      end

      # check that the status has been recently pushed
      click_on_first "Projects"
      click_on_first "Test Project"
      wait_until 5 do
        last_posted_at_before \
          < Time.parse(first("table td.status-pushes")['data-last-posted-at'])
      end

      wait_until 5 do
        File.exist?('tmp/last-status-post.yml') &&
          (YAML.load_file('tmp/last-status-post.yml')
           .with_indifferent_access[:body][:state] == 'success')
      end

      new_commit_sha = Helpers::DemoRepo.exec! 'git log -n 1 --format=%H'

      written_data = YAML.load_file('tmp/last-status-post.yml').with_indifferent_access
      expect(written_data[:auth_token]).to be== 'test-token'
      expect(written_data[:sha]).to be== new_commit_sha
      expect(written_data[:body][:state]).to be== 'success'
      expect(written_data[:body][:target_url]).to be_present
      expect(written_data[:body][:description]).to be_present
      expect(written_data[:body][:context]).to be_present


      ### with invalid token the state becomes 'error' ########################

      click_on_first 'Projects'
      click_on 'Test Project'
      click_on 'Edit'
      find('input#remote_api_token').set 'invalid-token'
      find("[type='submit']").click
      wait_until(10){first("table.table-project td.status-pushes.danger[data-state='error']")}


      ### with empty token the state becomes 'unaccessible' again #############

      click_on_first 'Projects'
      click_on 'Test Project'
      click_on 'Edit'
      find('input#remote_api_token').set ' '
      find("[type='submit']").click
      wait_until(10){first("table.table-project td.status-pushes.danger[data-state='unaccessible']")}


      ### if we disable it it becomes disabled again ##########################

      click_on_first 'Projects'
      click_on 'Test Project'
      click_on 'Edit'
      find("input.send_status_notifications").set(false)
      find("[type='submit']").click
      wait_until 5 do
        first("table.table-project td.status-pushes", text: 'disabled')
      end

  end

end
