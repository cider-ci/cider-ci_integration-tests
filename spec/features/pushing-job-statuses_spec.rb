require 'spec_helper'
require 'yaml'
require 'fileutils'

describe "Sending job statuses to a GitHub compatible API endpoint.",
  type: :feature do

  before :each do
    setup_signin_waitforcommits
  end

  let :github_api_mock_port do
    ENV['GITHUB_API_MOCK_PORT'].presence  \
      || fail("GITHUB_API_MOCK_PORT is not set")
  end

  it "The API mock writes the status and appropriate data into a file" do

      ### prepare #############################################################

      click_on 'Projects'
      wait_until { page.has_content? 'Demo Project'}
      click_on "Demo Project"
      click_on "Edit"

      find('input#api_token').set "test-token"

      find('input#remote_api_endpoint').set "http://localhost:#{github_api_mock_port}"
      find('input#remote_api_endpoint').set "http://localhost:#{github_api_mock_port}"

      find('input#remote_api_namespace').set "test-org"
      find('input#remote_api_namespace').set "test-org"

      find('input#remote_api_name').set "test-repo"
      find('input#remote_api_name').set "test-repo"

      find("[type='submit']").click


      ### run a job ###########################################################

      FileUtils.rm ['tmp/last-status-post.yml'], force: true

      run_job_on_last_commit 'Introduction Demo and Example Job'
      wait_for_job_state 'Introduction Demo and Example Job', 'passed'

      ### check for success status push #######################################

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


      ### check for success status push for new amended commit ################

      FileUtils.rm ['tmp/last-status-post.yml'], force: true

      Helpers::DemoRepo.exec! 'git commit --allow-empty -m "Some new commit with same tree_id" '
      Helpers::DemoRepo.git_update_server_info

      wait_until do
        page.has_content? "Some new commit"
      end

      wait_until 30 do
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

  end

end
