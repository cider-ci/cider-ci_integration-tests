require 'spec_helper'
require 'api/shared'
require 'uri'

describe 'When the "Dispatch-Storm Delay Demo" has passed', type: :feature do
  before :all do
    setup_signin_waitforcommits
    run_job_on_last_commit 'Dispatch-Storm Delay Demo'
    wait_for_job_state 'Dispatch-Storm Delay Demo', 'passed'
    @job_id = find('#job')['data-id']
  end

  it 't2 has been started about 20 seconds (the dispatch delay duration) '\
    'after t1, but they do overlap.' do

    t1, t2= authenticated_json_roa_client.get.relation("job").get(id: @job_id) \
      .relation("tasks").get().collection().map(&:get) \
      .map{|t| t.relation("trials").get().collection.map(&:get)}.flatten \
      .sort_by{|t| t.data[:started_at]}.map(&:data)

    t1_started_at = DateTime.parse(t1[:started_at])
    t1_finsihed_at= DateTime.parse(t1[:finished_at])
    t2_started_at = DateTime.parse(t2[:started_at])
    t2_finsihed_at= DateTime.parse(t2[:finished_at])

    # t2 roughly has been started 20 seconds after t1
    expect(t1_started_at + 15.seconds ).to be < t2_started_at
    expect(t1_started_at + 25.seconds ).to be > t2_started_at

    # t2 has been started before has t1 finished
    expect(t2_started_at).to be < t1_finsihed_at

  end
end
