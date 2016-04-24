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

  describe 'creating and querying jobs' do
    it 'works' do
      tree_id = authenticated_json_roa_client.get.relation(:commits) \
                .get(repository_url:  Helpers::DemoRepo.git_url,
                     branch_head: TEST_BRANCH) \
                .collection.first.get.data[:tree_id]

      create_job_relation = authenticated_json_roa_client.get.relation(:create_job)

      json_roa_create_job_response = create_job_relation.post({},
                  { tree_id: tree_id,
                    key: 'environment-variables' }.to_json,
                        content_type: 'application/json')

      expect(json_roa_create_job_response.response.status).to be_between(200,299)

      job_id = json_roa_create_job_response.data[:id]

      expect(job_id).to be

      wait_until do
        json_roa_job_response = authenticated_json_roa_client \
          .get.relation(:job).get(id: job_id)
        expect(json_roa_job_response.response.status).to be_between(200,299)
        json_roa_job_response.data[:state] == 'passed'
      end

      expect(authenticated_json_roa_client.get.relation(:jobs) \
             .get(tree_id: tree_id,
                  repository_url: Helpers::DemoRepo.git_url,
                  key: 'environment-variables',
                  branch_descendants: TEST_BRANCH,
                  branch_head: TEST_BRANCH,
                  state: 'passed').collection.first).to be

      expect(authenticated_json_roa_client.get.relation(:jobs) \
             .get(tree_id: '1111111111111111111111111111111111111111',
                  repository_url: Helpers::DemoRepo.git_url,
                  key: 'environment-variables',
                  branch_descendants: TEST_BRANCH,
                  branch_head: TEST_BRANCH,
                  state: 'passed').collection.first).not_to be

      expect(authenticated_json_roa_client.get.relation(:jobs) \
             .get(tree_id: tree_id,
                  repository_url: (Helpers::DemoRepo.git_url + '/X'),
                  key: 'environment-variables',
                  branch_descendants: TEST_BRANCH,
                  branch_head: TEST_BRANCH,
                  state: 'passed').collection.first).not_to be

      expect(authenticated_json_roa_client.get.relation(:jobs) \
             .get(tree_id: tree_id,
                  repository_url: Helpers::DemoRepo.git_url,
                  key: 'blah',
                  branch_descendants: TEST_BRANCH,
                  branch_head: TEST_BRANCH,
                  state: 'passed').collection.first).not_to be

      expect(authenticated_json_roa_client.get.relation(:jobs) \
             .get(tree_id: tree_id,
                  repository_url: Helpers::DemoRepo.git_url,
                  key: 'environment-variables',
                  branch_descendants: "#{TEST_BRANCH}X",
                  branch_head: TEST_BRANCH,
                  state: 'passed').collection.first).not_to be

      expect(authenticated_json_roa_client.get.relation(:jobs) \
             .get(tree_id: tree_id,
                  repository_url: Helpers::DemoRepo.git_url,
                  key: 'environment-variables',
                  branch_descendants: TEST_BRANCH,
                  branch_head: "#{TEST_BRANCH}X",
                  state: 'passed').collection.first).not_to be

      expect(authenticated_json_roa_client.get.relation(:jobs) \
             .get(tree_id: tree_id,
                  repository_url: Helpers::DemoRepo.git_url,
                  key: 'environment-variables',
                  branch_descendants: TEST_BRANCH,
                  branch_head: TEST_BRANCH,
                  state: 'failed').collection.first).not_to be
    end
  end
end
