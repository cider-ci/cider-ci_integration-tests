require 'spec_helper'

describe 'the job "Attachments-Demo" creates ', type: :feature do
  before :all do
    setup_signin_waitforcommits
    run_job_on_last_commit 'Attachments-Demo'
    wait_for_job_state 'Attachments-Demo', 'passed'
    @job_id = find('#job')['data-id']
  end

  before :each do
    sign_in_as 'adam'
  end

  context 'a tree-attachment which' do
    it 'can be browsed via the UI' do
      visit path_to_job(@job_id)
      click_on 'Tree-Attachments'
      click_on 'tree-attachment'
      expect(page).to have_content '/tmp/a-tree-attachment.txt'
      find('#open-content').click
      expect(page).to have_content 'I am a tree attachment!'
    end

    it 'can be viewed via the API Browser' do
      click_on 'API Browser'
      api_click_on_relation_method 'job', 'GET'
      api_continue_with_url_parameters({ id: @job_id }.to_json)
      api_click_on_relation_method 'tree-attachments', 'GET'
      api_click_on_first_collection_item_method 'GET'
      api_click_on_relation_method 'tree-attachment-data-stream', 'GET'
      expect(page).to have_content 'I am a tree attachment!'
      find('#open-content').click
      expect(page).to have_content 'I am a tree attachment!'
    end

    it 'can be accessed via the API' do
      tree_attachment = api_connection.get \
                        .relation('job').get('id' => @job_id) \
                        .relation('tree-attachments').get.collection.first.get
      expect(tree_attachment.data['path']).to match(/a-tree-attachment/)
      data_stream = tree_attachment \
                    .relation('tree-attachment-data-stream').get
      expect(data_stream.response.body.squish).to \
        be == 'I am a tree attachment!'
    end
  end

  context 'a trial-attachment which' do
    it 'can be browsed via the UI' do
      visit path_to_job(@job_id)
      first('tr.task a').click
      first('tr.trial a').click
      click_on 'Attachments'
      click_on 'trial-attachment'
      expect(page).to have_content '/tmp/a-trial-attachment.txt'
      find('#open-content').click
      expect(page).to have_content 'I am a trial attachment!'
    end

    it 'it can be viewed via the API Browser' do
      click_on 'API Browser'
      api_click_on_relation_method 'job', 'GET'
      api_continue_with_url_parameters({ id: @job_id }.to_json)
      api_click_on_relation_method 'tasks', 'GET'
      api_continue_with_url_parameters({}.to_json)
      api_click_on_first_collection_item_method 'GET'
      api_click_on_relation_method 'trials', 'GET'
      api_continue_with_url_parameters({}.to_json)
      api_click_on_first_collection_item_method 'GET'
      api_click_on_relation_method 'trial-attachments', 'GET'
      api_continue_with_url_parameters({}.to_json)
      api_click_on_first_collection_item_method 'GET'
      api_click_on_relation_method 'trial-attachment-data-stream', 'GET'
      expect(page).to have_content 'I am a trial attachment!'
      find('#open-content').click
      expect(page).to have_content 'I am a trial attachment!'
    end
  end
end
