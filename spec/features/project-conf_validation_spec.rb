require 'spec_helper'

describe 'Validating a project-configuration with a bogus key', type: :feature do

  before :each do
    setup_signin_waitforcommits
  end


  let :job_name do
    'Project spec with a bogus key'
  end

  let :message do
    "Replaced by #{job_name}".truncate(20)
  end


  let :cider_ci_config do <<-YAML.strip_heredoc
      bogus: whatever
      jobs: {}
    YAML
  end


  it 'ends up defective and has a corresponding issue.' do

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
    sign_in_as 'admin'
    click_on_first 'Workspace'
    wait_until { page.has_content? message }

    wait_until { first  "a .tree-issue-warning" }.click

    expect(find(".alert")).to have_content /Validation Error/

    expect(find(".alert")).to have_content /Unknown Property/

    expect(find(".alert")).to have_content /unknown property.*bogus/
  end

end
