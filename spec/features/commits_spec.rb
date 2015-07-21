require 'spec_helper'

describe 'The "Demo Project" repository', type: :feature do
  before :all do
    setup_signin_waitforcommits
  end

  before :each do
    sign_in_as 'adam'
  end

  context 'the Commits page' do
    before :each do
      click_on 'Commits'
    end

    it 'has at least one commit' do
      expect(all('#commits-table tbody tr').count).to be >= 1
    end

    context 'filtering by depth' do
      before :each do
        find('input#repository_names').set('Demo Project')
        find('input#branch_names').set('master')
      end

      context 'Branch heads only' do
        before :each do
          find('select#depth').select('Branch heads only')
          click_on('Filter')
        end

        it 'shows exactly 1 commit' do
          expect(all('#commits-table tbody tr').count).to be == 1
        end
      end

      context 'Up to depth 2' do
        before :each do
          find('select#depth').select('Up to depth 2')
          click_on('Filter')
        end

        it 'shows exactly 3 commits' do
          expect(all('#commits-table tbody tr').count).to be == 3
        end
      end
    end

    context 'filtering with autocomplete by repository_name, branch_name, ' \
      ' and text "Initial" with any depth'  do
      before :each do
        find('input#repository_names').set('demo')
        find('.ui-autocomplete').find('a', text: 'Demo Project').click
        find('input#branch_names').set('ma')
        find('.ui-autocomplete').find('a', text: 'master').click
        find('input#commit_text').set('Initial')
        find('select#depth').select('Any depth and orphans')
        click_on('Filter')
      end

      it 'finds the initial commit' do
        wait_until { all('#commits-table tbody tr').count > 0 }
      end
    end

    context '6 per page pagination' do
      before :each do
        find('select#per_page').select('6 Per page')
        find('select#depth').select('Any depth and orphans')
        click_on('Filter')
      end

      it 'shows 6 commits and has a next link' do
        expect(all('#commits-table tbody tr').count).to be == 6
        click_on('Next')
      end
    end

    context 'a new commit' do
      before :each do
        @branch_name = 'branch_' + Faker::Lorem.words.join('-')
        @commit_message = Faker::Lorem.sentence
        expect(Helpers::DemoRepo.create_a_new_branch_and_commit_cmd(
                 @branch_name, @commit_message)).to pass_execution
      end

      after :each do
        Helpers::DemoRepo.delete_branch_cmd(@branch_name)
      end

      it 'shows up on the commits page' do
        wait_until(20) { page.has_content? @commit_message }
      end
    end
  end
end
