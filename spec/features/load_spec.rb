require 'spec_helper'
require 'api/shared'

describe 'Testing the load', type: :feature do


  def set_executor_load ex_load
    Helpers::DemoExecutor.amend_config max_load: ex_load
    click_on_first 'Administration'
    click_on_first 'Executors'
    wait_until do
      page.has_content? "0.0 / #{ex_load.to_f}"
    end
  end

  before :each do
    setup_signin_waitforcommits
    set_executor_load 3
  end

  let :job_name do
    'Load Test'
  end

  let :message do
    job_name
  end


  describe "max_load = 3, three jobs each of load = 2 " do

    let :cider_ci_config do <<-YAML.strip_heredoc
      jobs:
        load:
          name: #{job_name}
          context:
            tasks:
              t1:
                load: 2
                scripts:
                  main:
                    body: sleep 15 && exit 0
              t2:
                load: 2
                scripts:
                  main:
                    body: sleep 15 && exit 0
              t3:
                load: 2
                scripts:
                  main:
                    body: sleep 15 && exit 0
          YAML
    end

    it  "let's exactly run two jobs in parallel" do

      Helpers::DemoRepo.reset!

      Dir.chdir Helpers::DemoRepo.system_path do
        File.open("cider-ci.yml", 'w') do |file|
          file.write cider_ci_config
        end
      end

      Helpers::DemoRepo.exec! <<-CMD.strip_heredoc
      git add --all .
      git commit -m #{Shellwords.escape message}
      CMD
      sign_in_as 'admin'
      click_on_first 'Workspace'
      wait_until { page.has_content? message }

      run_job_on_last_commit job_name
      wait_for_job_state job_name, 'passed'

      @job_id = find('#job')['data-id']

      trials = authenticated_json_roa_client.get.relation("job") \
        .get(id: @job_id).relation("tasks").get().collection() \
        .map(&:get).map{ |task| task.relation("trials").get() \
                         .collection.map(&:get).map(&:data)}

      trials_with_datetype= trials.flatten.map{|trial|
        trial.map{ |k,v|
          if k =~ /.*_at/ && v
            [k,DateTime.parse(v)]
          else
            [k,v]
          end
        }}.map(&:to_h).map(&:with_indifferent_access).sort_by{|x| x[:started_at]}


      # the trials have been started in strict order
      expect(trials_with_datetype[0][:started_at]).to be<  trials_with_datetype[1][:started_at]
      expect(trials_with_datetype[1][:started_at]).to be<  trials_with_datetype[2][:started_at]

      # the first and second do overlap, because the overload allows this
      expect(trials_with_datetype[0][:finished_at]).to be>  trials_with_datetype[1][:started_at]

      # the first and third do not overlap
      expect(trials_with_datetype[0][:finished_at]).to be< trials_with_datetype[2][:started_at]

    end

  end
end
