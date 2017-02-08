require 'spec_helper'

describe(" Given: job1 with run_when directive on brach matching ^test_.+$.
           Facts: job1 will not be run as long there is a project configuration
            preventing it. job1 will be run otherwise if a matching branch is
            created.
           ".strip_heredoc, type: :feature) do

  before :each do
    setup_signin_waitforcommits
  end

  let :cider_ci_config do <<-YAML.strip_heredoc
    jobs:
      job1:
        run_when:
          'branch with prefix test_ has been updated':
            type: branch
            include_match: ^test_.+$
        task: |
          :; exit 0
          exit /b 0
    YAML
  end

  let :message do
    'Job to run on branch update'
  end

  it '' do

    sign_in_as 'admin'

    # disable branch trigger for repository ##################################################

    click_on 'Projects'
    wait_until { page.has_content? 'Demo Project'}
    click_on "Demo Project"
    click_on "Edit"
    find('input#branch_trigger_include_match').set '$.+^'
    find("[type='submit']").click
    wait_until(10) { first(".modal") }
    wait_until(10) { ! first(".modal") }
    click_on_first 'Workspace'

    # setup project ###########################################################

    Helpers::DemoRepo.reset!

    Dir.chdir Helpers::DemoRepo.system_path do
      File.open("cider-ci.yml", 'w') do |file|
        file.write cider_ci_config
      end
    end

    Helpers::DemoRepo.exec! <<-CMD.strip_heredoc
        git add --all .
        git commit -m #{Shellwords.escape message}
        CMD

    click_on_first 'Workspace'
    wait_until { page.has_content? message }


    # commit test_1 branch will not cause a job to be created #################

    Helpers::DemoRepo.exec! <<-CMD.strip_heredoc
      git checkout -b 'test_1'
      CMD
    wait_until { page.has_content? "test_1"}
    sleep 10
    expect(page).not_to have_selector(".job[data-name='job1']")

    # (re­enable branch trigger for repository #################################

    click_on 'Projects'
    wait_until { page.has_content? 'Demo Project'}
    click_on "Demo Project"
    click_on "Edit"
    find('input#branch_trigger_include_match').set '^.+$'
    find('input#branch_trigger_exclude_match').set '$.+^'
    find("[type='submit']").click
    wait_until(10) { first(".modal") }
    wait_until(10) { ! first(".modal") }
    click_on_first 'Workspace'


    # commit test_2 branch will cause a job to be created #####################

    Helpers::DemoRepo.exec! <<-CMD.strip_heredoc
      git checkout -b 'test_2'
    CMD
    wait_until(15){ page.has_content?("test_2") }
    wait_until(15){ page.has_selector?(".job[data-name='job1']") }

  end

end
