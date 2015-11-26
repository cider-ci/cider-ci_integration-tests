require 'api/shared'
require 'set'

describe 'jobs, ' do

  before :all do
    Helpers::Misc.reset_and_configure
    wait_until do
      authenticated_json_roa_client.get \
        .relation(:commits).get.collection.first
    end
  end

  describe 'creating and querying jobs'  do

    it 'works' do

      tree_id= authenticated_json_roa_client.get.relation(:commits) \
        .get(repository_url:  Helpers::DemoRepo.git_url,
             branch_head: 'master') \
        .collection.first.get.data[:tree_id]

      job_id = authenticated_json_roa_client.get.relation(:create_job) \
        .post({},{tree_id: tree_id, key: 'environment-variables'}.to_json,
             content_type: 'application/json').data[:id]

      wait_until do
        authenticated_json_roa_client.get.relation(:job) \
          .get(id: job_id).data[:state] == 'passed'
      end

      expect( authenticated_json_roa_client.get.relation(:jobs) \
             .get(tree_id: tree_id,
                  repository_url: Helpers::DemoRepo.git_url,
                  key: 'environment-variables',
                  branch_descendants: 'master',
                  branch_head: 'master',
                  state: 'passed').collection.first ).to be

      expect( authenticated_json_roa_client.get.relation(:jobs) \
             .get(tree_id: '1111111111111111111111111111111111111111',
                  repository_url: Helpers::DemoRepo.git_url,
                  key: 'environment-variables',
                  branch_descendants: 'master',
                  branch_head: 'master',
                  state: 'passed').collection.first ).not_to be

      expect( authenticated_json_roa_client.get.relation(:jobs) \
             .get(tree_id: tree_id,
                  repository_url: (Helpers::DemoRepo.git_url + "/X"),
                  key: 'environment-variables',
                  branch_descendants: 'master',
                  branch_head: 'master',
                  state: 'passed').collection.first ).not_to be

      expect( authenticated_json_roa_client.get.relation(:jobs) \
             .get(tree_id: tree_id,
                  repository_url: Helpers::DemoRepo.git_url,
                  key: 'blah',
                  branch_descendants: 'master',
                  branch_head: 'master',
                  state: 'passed').collection.first ).not_to be

      expect( authenticated_json_roa_client.get.relation(:jobs) \
             .get(tree_id: tree_id,
                  repository_url: Helpers::DemoRepo.git_url,
                  key: 'environment-variables',
                  branch_descendants: 'masterX',
                  branch_head: 'master',
                  state: 'passed').collection.first ).not_to be

      expect( authenticated_json_roa_client.get.relation(:jobs) \
             .get(tree_id: tree_id,
                  repository_url: Helpers::DemoRepo.git_url,
                  key: 'environment-variables',
                  branch_descendants: 'master',
                  branch_head: 'masterX',
                  state: 'passed').collection.first ).not_to be


      expect( authenticated_json_roa_client.get.relation(:jobs) \
             .get(tree_id: tree_id,
                  repository_url: Helpers::DemoRepo.git_url,
                  key: 'environment-variables',
                  branch_descendants: 'master',
                  branch_head: 'master',
                  state: 'failed').collection.first ).not_to be

    end

  end

end

