require 'spec_helper'

feature 'Repository / Project update notifications.', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end

  context "
    A project has been successfully fetched.
    Its update interval is 1 hour, and it has not been updated
    in the last few seconds.
  ".strip_heredoc do
    before :each do
      sign_in_as 'admin'
      visit '/'
      click_on 'Projects'
      wait_until { page.has_content? 'Demo Project'}
      click_on 'Demo Project'
      click_on 'Edit'
      find('input#remote_fetch_interval').set '1 Hour'
      click_on 'Submit'
      wait_until(90){ page.has_content? 'fetched a minute ago' }
    end
    scenario"
    When posting a request to the specified URL we will observe
    that the project will have been updated a few seconds ago.
    ".strip_heredoc do
      url = find('#update_notification_url').text
      expect(Faraday.post(url).status).to be== 202
      wait_until { page.has_content? 'fetched a few seconds ago' }
    end
  end
end
