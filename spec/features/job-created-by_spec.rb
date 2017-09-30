require 'spec_helper'

describe 'Showing the creator of a job', type: :feature do
  before :each do
    setup_signin_waitforcommits
  end
  it 'can be seen when the job has been triggered manually' do
    sign_in_as 'admin'
    run_job_on_last_commit 'Introduction Demo and Example Job'
    expect(find('.created').text).to match /created .* by Adam Ambassador/
  end
end
