require 'spec_helper'

feature 'Admin manages Repositories', type: :feature do
  before :each do
    raise 'TODO replace ConfigurationManagement'
    Helpers::ConfigurationManagement.invoke_ruby 'PgTasks.truncate_tables() && "OK"'
    Helpers::Users.create_users
  end

  scenario 'Create a repository, editing and deleting it' do
    sign_in_as 'admin'
    visit '/'
    click_on 'Projects'


    # set up the project with disabled push hook management ###################

    wait_until { page.has_content? 'Add a new project'}
    click_on 'Add a new project'

    find('input#git_url').set Helpers::DemoRepo.system_path
    find('input#name').set 'TestRepo'
    click_on 'Submit'

    wait_until 5 do
      first("table.table-project td.push-hook[data-state='unmanaged']")
    end

    wait_until 5 do
      first("table.table-project td.push-notification.default")
    end


    # enable hook management and check that it is now "unavailable" ###########

    click_on 'Edit'
    find("input.manage_remote_push_hooks").set(true)
    click_on 'Submit'
    wait_until do
      first("table.table-project td.push-hook.danger[data-state='unavailable']")
    end

    # modify the project to enable the push-hook but with an illegal token ####
    click_on 'Edit'
    find('input#remote_api_token').set 'faux-token'
    find('input#remote_api_endpoint').set "http://localhost:#{ENV['GITHUB_API_MOCK_PORT']}"
    find('input#remote_api_namespace').set 'project-namespace'
    find('input#remote_api_name').set 'project-name'
    find('select#remote_api_type').select('github')
    click_on 'Submit'


    wait_until 10 do
      first("table.table-project td.push-hook.danger[data-state='error']")
    end


    # fix the token ###########################################################
    click_on 'Edit'
    find('input#remote_api_token').set 'test-token'
    click_on 'Submit'

    wait_until 10 do
      first("table.table-project td.push-hook.success[data-state='ok']")
    end

    wait_until 5 do
      first("table.table-project td.push-hook") \
        .text.match /a few seconds ago/
    end


    # check that the hook did sent a notification #############################

    wait_until 5 do
      first("table.table-project td.push-notification.success")
    end

    wait_until 5 do
      first("table.table-project td.push-notification") \
        .text.match /a few seconds ago/
    end


    # re trigger hook check manually and check that we received a new push notification

    push_hook_updated_at_before = Time.parse first("table.table-project td.push-hook")['data-updated-at']
    push_notification_received_at_before = Time.parse first("table.table-project td.push-notification")['data-received-at']
    find("table.table-project td.push-hook button.check-push-hook").click
    wait_until 5 do
      Time.parse(first("table.table-project td.push-hook")['data-updated-at']) > push_hook_updated_at_before
    end
    wait_until 5 do
      first("table.table-project td.push-hook.success[data-state='ok']")
    end
    push_hook_updated_at_after = Time.parse first("table.table-project td.push-hook")['data-updated-at']
    push_notification_received_at_after = Time.parse first("table.table-project td.push-notification")['data-received-at']

    expect(push_hook_updated_at_after).to be> push_hook_updated_at_before
    expect(push_notification_received_at_after).to be> push_notification_received_at_before


  end
end
