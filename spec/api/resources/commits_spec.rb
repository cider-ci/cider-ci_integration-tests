require 'api/shared'
require 'set'

describe 'commits' do
  before :each do
    Helpers::Misc.reset_and_configure
    wait_until do
      authenticated_json_roa_client.get \
        .relation(:commits).get.collection.first
    end
  end

  it '' do
    expect(
      authenticated_json_roa_client.get.response.status
    ).to be == 200

    expect(
      authenticated_json_roa_client
      .get.relation('commits').get.response.status
    ).to be == 200

    expect(
      authenticated_json_roa_client.get.relation('commits')
      .get('tree_id' => '6451155c768c3ee04c9b014dd15b3c4356741635')
      .response.status
    ).to be == 200

    expect(
      authenticated_json_roa_client.get.relation('commits')
      .get('tree_id' => '6451155c768c3ee04c9b014dd15b3c4356741635')
      .response.status
    ).to be == 200
  end

  describe 'commit' do
    it 'includes the expected keys' do
      expect(
        authenticated_json_roa_client.get.relation('commits')
        .get(tree_id: '6451155c768c3ee04c9b014dd15b3c4356741635')
        .collection.first.get.data.keys.map(&:to_sym)
      ).to include :tree_id, :committer_email, :committer_date, :author_email, :author_date
    end

    it 'relates to jobs' do
      expect(
        authenticated_json_roa_client.get.relation('commits')
        .get(tree_id: '6451155c768c3ee04c9b014dd15b3c4356741635')
        .collection.first.get.relation(:jobs)
      ).to be_a JSON_ROA::Client::Relation
    end
  end
end
