require 'spec_helper'

feature 'Repository / Project update notifications.', type: :feature do
  before :each do
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
    end
    scenario"
    When posting a request to the specified URL we will observe
    that the project will be fetched.
    ".strip_heredoc do
      wait_until { page.has_content? 'fetched a few seconds ago' }
      last_fetched_at_before = Time.parse(first("td.fetch-and-update")['data-last-fetched-at'])
      url = find('section.push-notifications #update_notification_url').text
      expect(Faraday.post(url).status).to be== 202
      wait_until do
        last_fetched_at_before < Time.parse(first("td.fetch-and-update")['data-last-fetched-at'])
      end
    end
  end
end
