require 'spec_helper'
require 'json_roa/client'

describe 'The job-result', type: :feature do
  before :all do
    setup_signin_waitforcommits
    run_job_on_last_commit 'Result-Demo'
    wait_for_job_state 'Result-Demo', 'passed'
    @job_id = find('#job')['data-id']
  end

  describe 'in the stats and progress bar ' do
    it 'shows the result property of the result' do
      visit path_to_job(@job_id)
      expect(find('.result-summary')).to have_content(/\d+\.\d+%/)
    end
  end

  describe 'the result link' do
    it ' leads to the result page which shows' \
    ' a yaml formatted output of the result structure' do
      visit path_to_job(@job_id)
      click_on('Result')
      expect(find('pre')).to have_content /value:\s+0\.\d+/
      expect(find('pre')).to have_content /summary:\s+\d+\.\d+%/
    end
  end

  describe 'in the summary badge' do
    it 'includes the job-name and the summary value of the result' do
      visit path_to_job(@job_id)
      job_name = first('.job')['data-name']
      repo_name = first('.repository')['data-name']
      branch_name = first('.branch')['data-name']
      visit '/cider-ci/ui/public' \
        "/#{repo_name}/#{branch_name}/#{job_name}/summary.svg"
      expect(first('.job-info')).to have_content /#{job_name}:\s+\d+\.\d+%/
    end
  end

  describe 'via the JSON-ROA API' do
    it 'can be reached via its job and has the value and summary properties' do
      result = api_connection.get \
               .relation('job').get('id' => @job_id).data['result']
      expect(result['value']).to be_a Float
      expect(result['summary']).to be_a String
    end
  end

  describe 'in the JSON-ROA API Browser' do
    it 'can be reached via its job and has the value and summary properties' do
      sign_in_as 'adam'
      click_on 'API Browser'
      api_click_on_relation_method 'job', 'GET'
      api_continue_with_url_parameters({ id: @job_id }.to_json)
      expect(find('#response-json-data-panel')).to have_content('result')
      expect(find('#response-json-data-panel')).to have_content('value')
      expect(find('#response-json-data-panel')).to have_content('summary')
    end
  end
end
