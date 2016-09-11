require 'api/shared'
require 'spec_helper'

feature 'Admin manages Repositories', type: :feature do

  before :each do
    Helpers::ConfigurationManagement.invoke_ruby 'PgTasks.truncate_tables() && "OK"'
    Helpers::Users.create_users
  end

  scenario 'Create a repository, editing and deleting it' do

    # wait until the internal db is updated and there are no
    # projects anymore
    wait_until do
      authenticated_json_roa_client.get.relation(:projects).get \
        .collection.count == 0
    end

    # created a projected and check it has been created
    created = authenticated_json_roa_client.get.relation(:projects).get \
      .relation(:create_project).post({},
        {name: 'Test Project',
         git_url: 'https://github.com/cider-ci/cider-ci.git'}.to_json,
         content_type: 'application/json')
    expect(created.response.status).to be== 201

    # the newly created project is listed
    expect(authenticated_json_roa_client.get.relation(:projects).get \
           .collection.count).to be== 1

    project_data = authenticated_json_roa_client.get.relation(:projects).get \
      .collection.first.get.data

    expect(project_data[:name]).to be== 'Test Project'

    # updating the project
    updated = authenticated_json_roa_client.get.relation(:projects).get \
      .collection.first.patch({},
        {name: 'Renamed Project'}.to_json, content_type: 'application/json')

    expect(updated.response.status).to be== 200

    expect(authenticated_json_roa_client.get.relation(:projects).get \
       .collection.first.get.data[:name]).to be== 'Renamed Project'

    # deleting  the project
    deleted = authenticated_json_roa_client.get.relation(:projects).get.collection.first.delete()
    expect(deleted.response.status).to be== 204

    # it is gone
    expect( authenticated_json_roa_client.get.relation(:projects).get \
        .collection.count).to be== 0

  end
end
