# # Testing the Git-Submodule Feature
#
# The jobs we use here are declared in the
# [`.cider-ci.yml` dotfile](https://github.com/cider-ci/cider-ci_demo-project-bash/blob/master/.cider-ci.yml)
# of the
# [Bash Demo Project for Cider-CI](https://github.com/cider-ci/cider-ci_demo-project-bash).
#
# The "Submodule-Demo" also tests the proper behavior itself. So all we need to
# do here is run it verify that it passes.
#
require 'spec_helper'

describe 'the job "Environment Variables Demo" ', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end
  it 'passes' do
    sign_in_as 'admin'
    run_job_on_last_commit 'Environment Variables Demo'
    wait_for_job_state 'Environment Variables Demo', 'passed'
  end
end
