require 'faraday'
require 'git'
require 'spec_helper'
require 'uri'


describe 'Project-Configuration', type: :feature do

  before :all do
    setup_signin_waitforcommits
  end

  let :config_files do
    %w(cider-ci.yml .cider-ci.yml cider-ci.json .cider-ci.json)
  end

  let :conn do
    base_url = "#{Capybara.app_host}/cider-ci/"
    Faraday.new(base_url) do |conn|
      conn.basic_auth('test-service', ENV['SERVICES_SECRET'])
      conn.adapter Faraday.default_adapter
      conn.headers['Accept'] = 'application/json'
    end
  end

  def delete_all_config_files
    config_files.each do |filename|
      Helpers::DemoRepo.remove_file filename
    end
  end

  context 'the response of getting the project-configuration ' do

    context 'when a file from a not resolved submodule is included ' do

      let :message do
        "Unresolvable submodule include"
      end

      let :response do
        Helpers::DemoRepo.reset!
        Dir.chdir Helpers::DemoRepo.system_path do
          File.open("cider-ci.yml", 'w') do |file|
            file.write <<-YAML.strip_heredoc
              include:
                - path: no-such-file.yml
                  submodule: ['no-such-submodule-path']
            YAML
          end
        end
        Helpers::DemoRepo.exec! <<-CMD.strip_heredoc
          git add --all .
          git commit -m #{Shellwords.escape message}
        CMD
        sign_in_as 'admin'
        click_on_first 'Workspace'
        wait_until { page.has_content? message }
        tree_id = Helpers::DemoRepo.tree_id
        conn.get "repositories/project-configuration/#{tree_id}"
      end

      it 'is NOT FOUND' do
        expect(response.status).to be == 404
      end

      it 'indicates a tree-issue on the workspace'  do
        expect(response.status).to be # we need to access response here because it is lazy
        first("a",text: "Workspace").click
        wait_until { first  "a .tree-issue-warning" }
      end

      it 'the tree page shows the corresponding tree-issue alert'  do
        expect(response.status).to be # we need to access response here because it is lazy
        first("a",text: "Workspace").click
        wait_until { first  "a .tree-issue-warning" }.click
        expect(page).to have_content "Project Configuration Error - Submodule could not be resolved"
      end

    end

    context 'when there is neither of the initial configuration files' do
      let :message do
        "Remove Cider-CI configuration file"
      end

      let :response do
        Helpers::DemoRepo.reset!
        Helpers::DemoRepo.exec! <<-CMD.strip_heredoc
          rm cider-ci.yml || true
          git add --all .
          git commit -m #{Shellwords.escape message}
        CMD
        sign_in_as 'admin'
        click_on_first 'Workspace'
        wait_until { page.has_content? message }
        tree_id = Helpers::DemoRepo.tree_id
        conn.get "repositories/project-configuration/#{tree_id}"
      end

      it 'indicates a tree-issue on the workspace'  do
        expect(response.status).to be # we need to access response here because it is lazy
        first("a",text: "Workspace").click
        wait_until { first  "a .tree-issue-warning" }
      end

      it 'the tree page shows the corresponding tree-issue alert'  do
        expect(response.status).to be # we need to access response here because it is lazy
        first("a",text: "Workspace").click
        wait_until { first  "a .tree-issue-warning" }.click
        expect(page).to have_content "Project Configuration Error"
        expect(page).to have_content /Neither configuration file .* was found/
      end

      it 'is NOT FOUND' do
        expect(response.status).to be == 404
      end

      it 'says that no configuration file was found' do
        expect(response.body).to match %r{Neither configuration file.*was found}
      end

    end


    context 'when a include is missing' do
      let :response do
        Helpers::DemoRepo.reset!
        Helpers::DemoRepo.exec! <<-CMD.strip_heredoc
          rm cider-ci/jobs/attachments.yml || true
          git add --all .
          git commit -m #{Shellwords.escape "Remove include cider-ci/jobs/attachments.yml"}
        CMD
        sign_in_as 'admin'
        click_on_first 'Workspace'
        wait_until { page.has_content? 'Remove include' }
        tree_id = Helpers::DemoRepo.tree_id
        conn.get "repositories/project-configuration/#{tree_id}"
      end

      it 'indicates a tree-issue on the workspace'  do
        expect(response.status).to be # we need to access response here because it is lazy
        first("a",text: "Workspace").click
        wait_until { first  "a .tree-issue-warning" }
      end

      it 'the tree page shows the corresponding tree-issue alert'  do
        expect(response.status).to be # we need to access response here because it is lazy
        first("a",text: "Workspace").click
        wait_until { first  "a .tree-issue-warning" }.click
        #expect(page).to have_content "Project Configuration Error"
        expect(page).to have_content /Path .* does not exist in .*/
      end

      it 'is NOT FOUND' do
        expect(response.status).to be == 404
      end

    end
  end
end
