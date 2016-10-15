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


    # set up project without push hook

    wait_until { page.has_content? 'Add a new project'}
    click_on 'Add a new project'

    find('input#git_url').set Helpers::DemoRepo.system_path
    find('input#name').set 'TestRepo'
    click_on 'Submit'

    wait_until do
      first("table.table-project td.push-hook.warning")
    end

    wait_until do
      first("table.table-project td.push-hook") \
        .text.match /setup is not possible/
    end

    wait_until do
      first("table.table-project td.push-notification.warning")
    end


    # modify project to enable push hook

    click_on 'Edit'

    find('input#api_token').set 'test-token'
    find('input#remote_api_endpoint').set "http://localhost:#{ENV['GITHUB_API_MOCK_PORT']}"
    find('input#remote_api_namespace').set 'project-namespace'
    find('input#remote_api_name').set 'project-name'
    find('select#remote_api_type').select('github')
    click_on 'Submit'

    # check that push hook has been set up automatically

    wait_until do
      first("table.table-project td.push-hook.success")
    end

    wait_until do
      first("table.table-project td.push-hook") \
        .text.match /a few seconds ago/
    end

    # check that the hook did sent a notification

    wait_until do
      first("table.table-project td.push-notification.success")
    end

    wait_until do
      first("table.table-project td.push-notification") \
        .text.match /a few seconds ago/
    end


    # re trigger hook check manually

    wait_until do
      first("table.table-project td.push-hook") \
        .text.match /a minute ago/
    end

    wait_until do
      first("table.table-project td.push-notification") \
        .text.match /a minute ago/
    end

    find("table.table-project td.push-hook button.check-push-hook").click

    # now check if the hook has been checked and triggered again

    wait_until do
      first("table.table-project td.push-hook") \
        .text.match /a few seconds ago/
    end

    wait_until do
      first("table.table-project td.push-notification") \
        .text.match /a few seconds ago/
    end




  end
end
