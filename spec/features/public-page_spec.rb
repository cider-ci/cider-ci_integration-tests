require 'spec_helper'

feature 'The public page, sign in and sign out', type: :feature do
  before :all do
    Helpers::ConfigurationManagement.invoke_ruby 'PgTasks.truncate_tables() && "OK"'
    Helpers::Users.create_users
  end
  scenario "Visiting '/' redirects to the public page" do
    visit '/'
    expect(current_path).to match(/.*\/public/)
  end
end
