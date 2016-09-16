require 'spec_helper'
require 'api/shared'
require 'fileutils'


describe 'The defective_trial_same_executor_redispatch_delay feature', type: :feature do

  before :all do
    File.open('../config/config.yml','w') { |file|
      file.write({'defective_trial_same_executor_redispatch_delay' => '15 Seconds'}.to_yaml)}
  end

  let :job_name do
    'job with defecting trials'
  end

  after :all do
    FileUtils.rm '../config/config.yml'
  end

  before :each do
    setup_signin_waitforcommits

    Helpers::DemoRepo.reset!
    Dir.chdir Helpers::DemoRepo.system_path do
      File.open("cider-ci.yml", 'w') do |file|
        file.write <<-YAML.strip_heredoc
        jobs:
          test:
            name: #{job_name}
            tasks:
              t1:
                scripts:
                  s1:
                    body: sleep 10
                    timeout: 1 Second
            YAML
      end
    end
    Helpers::DemoRepo.exec! <<-CMD.strip_heredoc
    git add --all .
    git commit -m #{Shellwords.escape job_name}
    CMD

  end

  let :config_files do
    %w(cider-ci.yml .cider-ci.yml cider-ci.json .cider-ci.json)
  end

  def delete_all_config_files
    config_files.each do |filename|
      Helpers::DemoRepo.remove_file filename
    end
  end

  context 'A job with always defecting trials' do

    context 'Without defective_trial_same_executor_redispatch_delay' do

      before :each do
        File.open('../config/config.yml','w') { |file|
          file.write({'defective_trial_same_executor_redispatch_delay' => nil}.to_yaml)}
      end

      it 'dispatches defective trials immediately' do

        sign_in_as 'admin'
        click_on_first 'Workspace'
        wait_until { page.has_content? job_name }
        run_job_on_last_commit job_name
        wait_for_job_state job_name, 'defective'
        job_id = find('#job')['data-id']

        t1, t2= authenticated_json_roa_client.get.relation("job").get(id: job_id) \
          .relation("tasks").get().collection().map(&:get) \
          .map{|t| t.relation("trials").get().collection.map(&:get)}.flatten \
          .sort_by{|t| t.data[:started_at]}.map(&:data)

        t1_started_at = DateTime.parse(t1[:started_at])
        t1_finsihed_at= DateTime.parse(t1[:finished_at])
        t2_started_at = DateTime.parse(t2[:started_at])
        t2_finsihed_at= DateTime.parse(t2[:finished_at])

        # t2 has been started quite immediately after t1 has been finished
        expect(t1_finsihed_at).to be < t2_started_at
        expect(t1_finsihed_at + 5.seconds ).to be > t2_started_at

      end
    end

    context 'With defective_trial_same_executor_redispatch_delay' do

      before :each do
        File.open('../config/config.yml','w') { |file|
          file.write({'defective_trial_same_executor_redispatch_delay' => 15}.to_yaml)}
      end

      it 'dispatches defective trials after the delay has passed' do

        sign_in_as 'admin'
        click_on_first 'Workspace'
        wait_until { page.has_content? job_name }
        run_job_on_last_commit job_name
        wait_for_job_state job_name, 'defective'
        job_id = find('#job')['data-id']

        t1, t2= authenticated_json_roa_client.get.relation("job").get(id: job_id) \
          .relation("tasks").get().collection().map(&:get) \
          .map{|t| t.relation("trials").get().collection.map(&:get)}.flatten \
          .sort_by{|t| t.data[:started_at]}.map(&:data)

        t1_started_at = DateTime.parse(t1[:started_at])
        t1_finsihed_at= DateTime.parse(t1[:finished_at])
        t2_started_at = DateTime.parse(t2[:started_at])
        t2_finsihed_at= DateTime.parse(t2[:finished_at])

        # t2 has been started after the delay t1 has been finished
        expect(t1_finsihed_at + 15.seconds ).to be < t2_started_at

      end
    end



  end
end
