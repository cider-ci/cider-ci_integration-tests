require 'faraday'
require 'git'
require 'spec_helper'
require 'uri'

describe 'Project-Configuration', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end

  let :demo_repo do
    Git.open('../demo-project-bash',
             repository: '../.git/modules/demo-project-bash',
             index: '../.git/modules/demo-project-bash/index')
  end

  let :config_files do
    %w(cider-ci.yml .cider-ci.yml cider-ci.json .cider-ci.json)
  end

  def update_server_info(demo_repo)
    demo_repo.chdir do
      system('git update-server-info') || fail('update-server-info failed')
    end
  end

  let :conn do
    base_url = "#{Capybara.app_host}/cider-ci/"
    Faraday.new(base_url) do |conn|
      conn.basic_auth('x', 'secret')
      conn.adapter Faraday.default_adapter
    end
  end

  def setup_demo_repo
    demo_repo.reset_hard('master')
    demo_repo.branch('master').checkout
    demo_repo.branch('test').delete rescue nil
    demo_repo.branch('test').checkout
  end

  def delete_all_config_files(demo_repo)
    demo_repo.chdir do
      config_files.each do |file|
        if File.exist?(file)
          (system("git rm \"#{file}\"") or (raise 'git rm failed'))
        end
      end
    end
  end

  context 'the response of getting the project-configuration '  do
    context 'of master' do
      let :response do
        setup_demo_repo
        tree_id = demo_repo.object('master').gtree.sha
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

    context 'parsing error' do
      context 'response for malformed json' do
        let :response_for_malformed_json do
          setup_demo_repo
          delete_all_config_files demo_repo
          demo_repo.chdir do
            File.open('cider-ci.json', 'w') do |file|
              file.write 'bogus'
            end
          end
          demo_repo.add
          message = 'Write bogus in cider-ci.json'
          demo_repo.commit(message)
          update_server_info demo_repo
          sign_in_as 'adam'
          click_on 'Commits'
          wait_until { page.has_content? message }
          tree_id = demo_repo.object('test').gtree.sha
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
          setup_demo_repo
          delete_all_config_files demo_repo
          demo_repo.chdir do
            File.open('cider-ci.yml', 'w') do |file|
              file.write 'x: { - }'
            end
          end
          demo_repo.add
          message = 'Write bogus in cider-ci.yml'
          demo_repo.commit(message)
          update_server_info demo_repo
          sign_in_as 'adam'
          click_on 'Commits'
          wait_until { page.has_content? message }
          tree_id = demo_repo.object('test').gtree.sha
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

    context 'for any of the four configuration options' do
      before :each do
        setup_demo_repo
      end

      def config_file_content(path)
        { 'path' => path }
      end

      def response_for_config_file(path)
        delete_all_config_files demo_repo
        demo_repo.chdir do
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

        demo_repo.add
        message = "Use #{path} as configfile"
        demo_repo.commit(message)
        update_server_info demo_repo
        sign_in_as 'adam'
        click_on 'Commits'
        wait_until { page.has_content? message }
        tree_id = demo_repo.object('test').gtree.sha
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

    context 'when there is neither of the initial configuration files' do
      let :response do
        setup_demo_repo
        demo_repo.remove('cider-ci.yml')
        demo_repo.commit('Remove configuration file')
        update_server_info demo_repo
        sign_in_as 'adam'
        click_on 'Commits'
        wait_until { page.has_content? 'Remove configuration file' }
        tree_id = demo_repo.object('test').gtree.sha
        conn.get "repositories/project-configuration/#{tree_id}"
      end

      it 'is NOT FOUND' do
        expect(response.status).to be == 404
      end

      it 'says that no configuration file was found' do
        expect(response.body).to match %r{Neither configuration file.*was found}
      end

      # TODO: got to project-configuration in the UI
      # and see that there is a meaninful message
    end

    context 'when a include is missing' do
      let :response do
        setup_demo_repo
        demo_repo.remove('cider-ci/jobs/attachments.yml')
        demo_repo.commit('Remove include cider-ci/jobs/attachments.yml')
        update_server_info demo_repo
        sign_in_as 'adam'
        click_on 'Commits'
        wait_until { page.has_content? 'Remove include' }
        tree_id = demo_repo.object('test').gtree.sha
        conn.get "repositories/project-configuration/#{tree_id}"
      end

      it 'is NOT FOUND' do
        expect(response.status).to be == 404
      end

      it 'says that the path was not found' do
        expect(response.body).to match %r{path.*attachments.*not found}
      end

      # TODO: got to project-configuration in the UI
      # and see that there is a meaninful message
    end
  end
end
