require 'spec_helper'

describe 'the job "Generate Tasks Demo" ', type: :feature do
  before :each do
    setup_signin_waitforcommits
  end

  context "Generate Tasks Demo" do
    it 'passes and the generated task is present' do

      sign_in_as 'admin'
      run_job_on_last_commit 'Generate Tasks Demo'
      wait_for_job_state 'Generate Tasks Demo', 'passed'

      # check that generated task is there
      expect(page).to have_content "specs/test1_spec.sh"
    end
  end

  context "Generate Tasks for Submodules Demo" do
    it 'passes and the generated task is present' do

      sign_in_as 'admin'
      run_job_on_last_commit 'Generate Tasks for Submodules Demo'
      wait_for_job_state 'Generate Tasks for Submodules Demo', 'passed'

      # check that generated task is there
      expect(page).to have_content "data/007"
    end
  end


end

