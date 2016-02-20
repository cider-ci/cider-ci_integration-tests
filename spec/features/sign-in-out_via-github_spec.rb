require 'spec_helper'

feature 'The public page, sign in and sign out', type: :feature do
  before :each do
    Helpers::ConfigurationManagement.invoke_ruby 'PgTasks.truncate_tables() && "OK"'
  end

  scenario 'Sign in as email-accepted admin "adam"' do
    visit '/'
    click_on 'Sign in via GitHub'
    click_on 'Sign in as adam'
    expect(page).to have_content 'Administration'
    expect(page).to have_content 'adam'

    users = JSON.parse(Helpers::ConfigurationManagement \
     .invoke_ruby('User.all')).with_indifferent_access[:result]

    expect(users.count).to be == 1
    expect(users.first[:login]).to be == 'adam@GitHubMock'
    expect(users.first[:is_admin]).to be == true
  end

  scenario 'Sign in as org-accepted user "normin"' do
    visit '/'
    click_on 'Sign in via GitHub'
    click_on 'Sign in as normin'
    expect(page).to have_content 'Workspace'
    expect(page).to have_content 'normin'

    users = JSON.parse(Helpers::ConfigurationManagement \
     .invoke_ruby('User.all')).with_indifferent_access[:result]

    expect(users.count).to be == 1
    expect(users.first[:login]).to be == 'normin@GitHubMock'
    expect(users.first[:is_admin]).to be == false
  end

  scenario 'Sign in as "Admin" team accepted user "tessa" and
    check updated-attributes on re-login' do
    visit '/'
    click_on 'Sign in via GitHub'
    click_on 'Sign in as tessa'
    expect(page).to have_content 'Workspace'
    expect(page).to have_content 'tessa'

    users = JSON.parse(Helpers::ConfigurationManagement \
     .invoke_ruby('User.all')).with_indifferent_access[:result]

    # tessa, after being created, is an admin

    expect(users.count).to be == 1
    expect(users.first[:login]).to be == 'tessa@GitHubMock'
    expect(users.first[:is_admin]).to be == true

    # set is_admin property of tessa to be false and verify

    Helpers::ConfigurationManagement \
      .invoke_ruby('User.first.update_attributes! is_admin: false')

    users = JSON.parse(Helpers::ConfigurationManagement \
     .invoke_ruby('User.all')).with_indifferent_access[:result]

    expect(users.count).to be == 1
    expect(users.first[:login]).to be == 'tessa@GitHubMock'
    expect(users.first[:is_admin]).to be == false

    # when tessa signs in again, the account will be updated to
    # be an admin again

    sign_out

    visit '/'
    click_on 'Sign in via GitHub'
    click_on 'Sign in as tessa'

    users = JSON.parse(Helpers::ConfigurationManagement \
     .invoke_ruby('User.all')).with_indifferent_access[:result]

    expect(users.count).to be == 1
    expect(users.first[:login]).to be == 'tessa@GitHubMock'
    expect(users.first[:is_admin]).to be == true

  end

  scenario 'Try to sign in as "silvan" with no matching strategy fails ' \
    'and does not create an user account' do
    visit '/'
    click_on 'Sign in via GitHub'
    click_on 'Sign in as silvan'
    expect(page).to have_content 'Not Authorized To Sign In'

    users = JSON.parse(Helpers::ConfigurationManagement \
     .invoke_ruby('User.all')).with_indifferent_access[:result]

    expect(users.count).to be == 0
  end

end
