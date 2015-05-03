# # Testing the Ports Feature
#
# The jobs we use here are declared in the
# [`.cider-ci.yml` dotfile](https://github.com/cider-ci/cider-ci_demo-project-bash/blob/master/.cider-ci.yml)
# of the
# [Bash Demo Project for Cider-CI](https://github.com/cider-ci/cider-ci_demo-project-bash).
#
# The "Ports-Demo" also tests the proper behavior itself. So all we need to
# do here is run it verify that it passes.
#
require 'spec_helper'

describe 'the job "Ports Demo" ', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end
  it 'passes' do
    sign_in_as 'adam'
    run_job_on_last_commit 'Ports Demo'
    wait_for_job_state 'Ports Demo', 'passed'
  end
end
