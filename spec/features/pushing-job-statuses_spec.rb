require 'spec_helper'
require 'yaml'

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

      click_on "Administration"
      click_on "Repositories"
      first("tr.repository a").click
      click_on "Edit"

      find('input#repository_foreign_api_endpoint').set "http://localhost:#{github_api_mock_port}"
      find('input#repository_foreign_api_authtoken').set "test-token"
      find('input#repository_foreign_api_owner').set "test-org"
      find('input#repository_foreign_api_repo').set "test-repo"
      find("form *[type='submit']").click

      run_job_on_last_commit 'Introduction Demo and Example Job'
      wait_for_job_state 'Introduction Demo and Example Job', 'passed'

      wait_until 10 do
        File.exist?('tmp/last-status-post.yml') &&
          (YAML.load_file('tmp/last-status-post.yml')
           .with_indifferent_access[:body][:state] == 'success')
      end

      written_data = YAML.load_file('tmp/last-status-post.yml').with_indifferent_access
      expect(written_data[:auth_token]).to be== 'test-token'
      expect(written_data[:body][:state]).to be== 'success'
      expect(written_data[:body][:target_url]).to be_present
      expect(written_data[:body][:description]).to be_present
      expect(written_data[:body][:context]).to be_present

  end

end
