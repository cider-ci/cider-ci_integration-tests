require 'spec_helper'

feature 'The public page, sign in and sign out', type: :feature do
  before :each do
    Helpers::ConfigurationManagement.invoke_ruby 'PgTasks.truncate_tables() && "OK"'
    Helpers::Users.create_users
  end

  scenario 'Sign in and sign out' do
    sign_in_as 'normin'
    expect(page).to have_content 'been signed in'
    expect(page).to have_content 'normin'
    sign_out
    expect(page).to have_content 'been signed out'
    expect(page).not_to have_content 'normin'
  end

  scenario 'Trying to sign-in by password when password '\
    'sign-in is not allowed fails.' do
    Helpers::ConfigurationManagement.invoke_ruby <<-EOS.strip_heredoc
      User.find_by(login: 'normin').update_attributes!(
      password_sign_in_allowed: false)
    EOS
    sign_in_as 'normin'
    expect(page).to have_content \
      'Password authentication is not allowed for this account!'
    expect(page).not_to have_content 'normin'
  end

  scenario 'Trying to sign-in when account is not enabled.' do
    Helpers::ConfigurationManagement.invoke_ruby <<-EOS.strip_heredoc
      User.find_by(login: 'normin').update_attributes!(
      account_enabled: false)
    EOS
    sign_in_as 'normin'
    expect(page).to have_content \
      'This account is disabled! '
    expect(page).not_to have_content 'normin'
  end

  scenario 'Try to sign in with wrong login' do
    visit '/'
    click_on 'Sign in with password'
    find("form#password-sign-in  input[type='text']").set 'adminfaux'
    find("form#password-sign-in  input[type='password']").set 'secret'
    find("form#password-sign-in  button[type='submit']").click
    expect(page).to have_content 'Neither login nor email address found'
  end

  scenario 'Sign-in with wrong password' do
    visit '/' unless current_path
    click_on 'Sign in with password'
    find("form#password-sign-in input[type='text']").set 'normin'
    find("form#password-sign-in input[type='password']").set 'bogus password'
    find("form#password-sign-in button[type='submit']").click
    expect(page).to have_content 'authentication failed'
  end

  scenario 'Set email and sign in by email' do
    sign_in_as 'normin'
    find('a#user-actions').click
    click_on('Account')
    find('input#email_address').set 'normin@example.com'
    click_on('Add email address')
    expect(page).to have_content 'address has been added'
    sign_out
    expect(page).to have_content '401 Unauthorized'
    click_on 'Sign in with password'
    find("form#password-sign-in input[type='text']").set 'normin@example.com'
    find("form#password-sign-in input[type='password']").set 'secret'
    find("form#password-sign-in button[type='submit']").click
    expect(page).to have_content 'been signed in'
  end
end
