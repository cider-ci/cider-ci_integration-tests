require 'spec_helper'
require 'api/shared'
require 'uri'

describe "" do


  describe 'When the "Exclusive Executor Resource with Templated Port" has passed',
    type: :feature do

    let :job_name do
      "Exclusive Executor Resource with Templated Port"
    end

    before :each do
      setup_signin_waitforcommits
      run_job_on_last_commit job_name
      wait_for_job_state job_name, 'passed'
      @job_id = find('#job')['data-id']
    end

    it 'the exclusive_executor_resource value has been templated; the scripts ' \
      'belonging to one task do not overlap; but the scripts of different tasks do' do

      scripts = authenticated_json_roa_client.get.relation("job").get(id: @job_id) \
        .relation("tasks").get().collection().map(&:get).map{ |task|
        task.relation("trials").get().collection.map(&:get).map{ |trial|
          trial.relation("scripts").get().collection.map(&:get).map(&:data).map{ |script_data|
            script_data.map{ |k,v|
              if k =~ /.*_at/ && v
                [k,DateTime.parse(v)]
              else
                [k,v]
              end
            }.to_h}}}.flatten.map(&:with_indifferent_access)

        task1_script1, task1_script2, task2_script1, task2_script2 =  scripts

        task1_script1_port = task1_script1[:environment_variables][:TEST_PORT]
        task1_script2_port = task1_script2[:environment_variables][:TEST_PORT]
        expect(task1_script2_port).to be== task1_script1_port

        task2_script1_port = task2_script1[:environment_variables][:TEST_PORT]
        task2_script2_port = task2_script2[:environment_variables][:TEST_PORT]
        expect(task2_script2_port).to be== task2_script1_port

        expect(task1_script1[:exclusive_executor_resource]).to be==
          "/tmp/exclusive-executor-resource_on_#{task1_script1_port}.txt"
        expect(task1_script2[:exclusive_executor_resource]).to be==
          "/tmp/exclusive-executor-resource_on_#{task1_script1_port}.txt"

        expect(task2_script1[:exclusive_executor_resource]).to be==
          "/tmp/exclusive-executor-resource_on_#{task2_script1_port}.txt"
        expect(task2_script2[:exclusive_executor_resource]).to be==
          "/tmp/exclusive-executor-resource_on_#{task2_script1_port}.txt"


        # task1_script1 and task1_script2 do not overlap
        # because that would overlap the exclusive_executor_resource directive
        expect(task1_script1[:finished_at]).to be<= task1_script2[:started_at]

        # task2_script1 and task2_script2 do not overlap
        # because that would overlap the exclusive_executor_resource directive
        expect(task2_script1[:finished_at]).to be<= task2_script2[:started_at]


        # task1_script1 and task2_script1 do overlap, (they can overlap
        # wrt exclusive_executor_resource because of the port), they overlap
        # because the executor has more than one slot
        expect( (task1_script1[:started_at] <= task2_script1[:started_at]) \
               && (task2_script1[:started_at]  <= task1_script1[:finished_at]) \
               || (task2_script1[:started_at] <= task1_script1[:started_at]) \
               && (task1_script1[:started_at]  <= task2_script1[:finished_at])).to be true

    end
  end
end
