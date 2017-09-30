require 'faraday'
require 'git'
require 'spec_helper'
require 'uri'


describe 'Project-Configuration', type: :feature do
  before :each do
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
    context "of #{TEST_BRANCH}" do
      let :response do
        Helpers::DemoRepo.reset!
        tree_id = Helpers::DemoRepo.tree_id
        conn.get "repositories/project-configuration/#{tree_id}"
      end

      it 'is OK' do
        expect(response.status).to be == 200
      end

      it 'is JSON' do
        expect(response.headers['content-type']).to \
          match %r{application/json; charset=UTF-8}
      end
    end

    context 'for any of the four configuration options' do
      before :each do
        Helpers::DemoRepo.reset!
      end

      def config_file_content(path)
        { 'path' => path }
      end

      def response_for_config_file(path)
        delete_all_config_files
        Dir.chdir(Helpers::DemoRepo.system_path) do
          File.open(path, 'w') do |file|
            if path =~ /yml$/
              file.write(config_file_content(path).to_yaml)
            elsif path =~ /json$/
              file.write(config_file_content(path).to_json)
            else
              fail "do not recognize #{path}"
            end
          end
        end
        message = "Use #{path} as configfile"
        Helpers::DemoRepo.exec! <<-CMD.strip_heredoc
          git add --all .
          git commit -m #{Shellwords.escape(message)}
        CMD
        sign_in_as 'admin'
        click_on_first 'Workspace'
        wait_until { page.has_content? message }
        tree_id = Helpers::DemoRepo.tree_id
        conn.get "repositories/project-configuration/#{tree_id}"
      end

      context 'cider-ci.yml' do
        it 'passes' do
          response = response_for_config_file('cider-ci.yml')
          expect(response.status).to be == 200
          expect(JSON.parse(response.body)).to be == config_file_content('cider-ci.yml')
        end
      end

      context 'cider-ci.yml' do
        it 'passes' do
          response = response_for_config_file('.cider-ci.yml')
          expect(response.status).to be == 200
          expect(JSON.parse(response.body)).to be == config_file_content('.cider-ci.yml')
        end
      end

      context 'cider-ci.json' do
        it 'passes' do
          response = response_for_config_file('cider-ci.json')
          expect(response.status).to be == 200
          expect(JSON.parse(response.body)).to be == config_file_content('cider-ci.json')
        end
      end

      context '.cider-ci.json' do
        it 'passes' do
          response = response_for_config_file('.cider-ci.json')
          expect(response.status).to be == 200
          expect(JSON.parse(response.body)).to be == config_file_content('.cider-ci.json')
        end
      end
    end

  end
end
