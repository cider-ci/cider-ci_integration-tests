
require 'spec_helper'

describe 'The workspace page', type: :feature do
  before :each do
    setup_signin_waitforcommits
  end

  it 'shows expected things' do
    expect(page).to have_content 'My Workspace'
    expect(find('li.branch', text: "0 #{TEST_BRANCH}")).to be
  end

  it "the 'Workspace' link leads to 'My Workspace' " do
    expect(page).not_to have_content 'Initial commit'
    find('select#depth').select('Any depth')
    find('input#commits_text_search').set 'initial'
    click_on 'Filter'
    expect(page).to have_content 'My Workspace' # filter sets My Workspace
    expect(page).to have_content 'Initial commit'

    click_on_first 'Cider-CI'
    # we are on the public page
    expect(page).to have_content 'About Cider-CI'
    click_on_first 'Workspace'
    # I have been redirected to My Workspace
    expect(page).to have_content 'My Workspace'
    # the previously set filters are active
    expect(page).to have_content 'Initial commit'
  end

  it "sign in on the public page leads to 'My Workspace'" do
    expect(page).not_to have_content 'Initial commit'
    find('select#depth').select('Any depth')
    find('input#commits_text_search').set 'initial'
    click_on 'Filter'
    expect(page).to have_content 'My Workspace' # filter sets My Workspace
    expect(page).to have_content 'Initial commit'

    click_on_first 'Cider-CI'
    # we are on the public page
    sign_out
    sign_in_as 'admin'
    # I have been redirected to My Workspace
    expect(page).to have_content 'My Workspace'
    # the previously set filters are active
    expect(page).to have_content 'Initial commit'
  end
end
