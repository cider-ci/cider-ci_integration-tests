require 'spec_helper'

feature 'Admin manages Repositories', type: :feature do
  before :all do
    Helpers::ConfigurationManagement.invoke_ruby 'PgTasks.truncate_tables()'
    Helpers::Users.create_users
  end

  scenario 'Create a repository, editing and deleting it' do
    sign_in_as 'adam'
    visit '/'
    click_on 'Administration'
    click_on 'Repositories'
    click_on 'Add a new repository'
    find('input#repository_name').set 'TestRepo'
    find('input#repository_git_url').set \
      'https://github.com/cider-ci/cider-ci_demo-project-bash.git'
    click_on 'Create'
    expect(page).to have_content 'created'
    click_on 'TestRepo'
    click_on 'Edit'
    find('input#repository_name').set 'UpdatedName'
    click_on 'Save'
    expect(page).to have_content 'updated'
    expect(page).to have_content 'UpdatedName'
    click_on 'Delete'
    expect(page).to have_content 'deleted'
  end
end
