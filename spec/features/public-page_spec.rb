require 'spec_helper'

feature 'The public page, sign in and sign out', type: :feature do
  before :each do
    db_clean
    Helpers::Users.create_users
  end
  scenario "Visiting '/cider-ci/ui/public' shows the public page" do

    $logger.warn "Visiting #{http_base_url}/cider-ci/ui/public"
    $logger.warn "driver: #{Capybara.current_driver}"

    visit '/cider-ci/ui/public'
    expect(page).to have_content 'Cider-CI'
  end
end
