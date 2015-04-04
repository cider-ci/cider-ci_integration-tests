require 'spec_helper'

describe 'Setting up the demo repository', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end

  before :each do
    sign_in_as 'adam'
  end

  it 'shows the Commits' do
    click_on 'Commits'
    expect(all('#commits-table tbody tr').count).to be > 0
  end

  it 'lets us filter the commits' do
    click_on 'Commits'
    find('input#repository_names').set('demo')
    find('.ui-autocomplete').find('a', text: 'DemoRepoBash').click
    find('input#branch_names').set('ma')
    find('.ui-autocomplete').find('a', text: 'master').click
    find('input#commit_text').set('Initial')
    click_on('Filter')
    wait_until { all('#commits-table tbody tr').count > 0 }
  end

  it 'lets us paginate the commits' do
    click_on 'Commits'
    find('select#per_page').select('6 Per page')
    click_on('Filter')
    expect(all('#commits-table tbody tr').count).to be == 6
    click_on('Next')
  end

  context 'and creating a new commit' do
    it 'will show up on the commits page' do
      click_on 'Commits'
      branch_name = 'branch_' + Faker::Lorem.words.join('-')
      commit_message = Faker::Lorem.sentence

      expect(Helpers::DemoRepo.create_a_new_branch_and_commit_cmd(
               branch_name, commit_message)).to pass_execution

      wait_until(20) { page.has_content? commit_message }

      expect(Helpers::DemoRepo.delete_branch_cmd(
               branch_name)).to pass_execution
    end
  end
end
