require 'spec_helper'

feature 'Admin manages Repositories', type: :feature do
  before :all do
    Helpers::ConfigurationManagement.invoke_ruby 'PgTasks.truncate_tables() && "OK"'
    Helpers::Users.create_users
  end

  scenario 'Create a repository, editing and deleting it' do
    sign_in_as 'admin'
    visit '/'
    click_on 'Projects'
    wait_until { page.has_content? 'Add a new project'}
    click_on 'Add a new project'
    find('input#git_url').set 'https://github.com/cider-ci/cider-ci_demo-project-bash.git'
    find('input#name').set 'TestRepo'
    find('input#name').set 'TestRepo'
    click_on 'Submit'
    wait_until { page.has_content?  /Project\s+"TestRepo"/ }
    wait_until { page.has_content?  /Edit/ }
    click_on 'Edit'
    find('input#name').set 'UpdatedName'
    # set other fields too
    # binding.pry
    click_on 'Submit'
    wait_until { page.has_content?  /Project\s+"UpdatedName"/ }
    click_on 'Delete'
    wait_until { page.has_content?  /Add a new project/ }
    expect(page).not_to have_content "UpdatedName"
  end
end
