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


    context 'parsing error' do
      context 'response for malformed json' do
        let :response_for_malformed_json do
          Helpers::DemoRepo.reset!
          delete_all_config_files
          Dir.chdir Helpers::DemoRepo.system_path do
            File.open('cider-ci.json', 'w') do |file|
              file.write 'bogus'
            end
          end
          message = 'Write bogus in cider-ci.json'
          Helpers::DemoRepo.exec! <<-CMD.strip_heredoc
            git add --all .
            git commit -m #{Shellwords.escape message}
          CMD
          sign_in_as 'admin'
          click_on_first 'Workspace'
          wait_until { page.has_content? message }
          tree_id = Helpers::DemoRepo.tree_id
          puts tree_id
          conn.get "repositories/project-configuration/#{tree_id}"
        end

        it 'fails with status 422' do
          expect(response_for_malformed_json.status).to be == 422
        end

        it 'the body contains "Parser error"' do
          expect(response_for_malformed_json.body).to match /Parser error/
        end
      end

      context 'response for malformed yml' do
        let :response_for_malformed_yml do
          Helpers::DemoRepo.reset!
          delete_all_config_files
          Dir.chdir Helpers::DemoRepo.system_path do
            File.open('cider-ci.yml', 'w') do |file|
              file.write 'x: { - }'
            end
          end
          message = 'Write bogus in cider-ci.yml'
          Helpers::DemoRepo.exec! <<-CMD.strip_heredoc
            git add --all .
            git commit -m #{Shellwords.escape message}
          CMD
          sign_in_as 'admin'
          click_on_first 'Workspace'
          wait_until { page.has_content? message }
          tree_id = Helpers::DemoRepo.tree_id
          puts tree_id
          conn.get "repositories/project-configuration/#{tree_id}"
        end

        it 'fails with status 422' do
          expect(response_for_malformed_yml.status).to be == 422
        end

        it 'the body contains "Parser error"' do
          expect(response_for_malformed_yml.body).to match /Parser error/
        end
      end
    end

  end
end
