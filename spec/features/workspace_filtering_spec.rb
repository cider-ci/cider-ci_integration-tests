require 'spec_helper'

describe 'The workspace page', type: :feature do
  before :each do
    setup_signin_waitforcommits
  end

  before :each do
    sign_in_as 'admin'
    click_on_first 'Workspace'
    click_on 'Reset'
  end

  describe 'can be filtered' do
    it 'by text-search' do
      expect(page).not_to have_content 'Initial commit'
      find('select#depth').select('Any depth')
      find('input#commits_text_search').set 'initial'
      click_on 'Filter'
      expect(page).to have_content 'Initial commit'
    end

    describe 'by branches' do
      it 'by string' do
        expect(all('tr.commit').size).to be >= 1
        find('input#branch_name').set 'gabeldigoo'
        click_on 'Filter'
        expect(all('tr.commit').size).to be == 0
      end

      it 'by comma separated strings' do
        find('input#branch_name').set "gabeldigoo, #{TEST_BRANCH}"
        click_on 'Filter'
        expect(all('tr.commit').size).to be >= 0
      end

      it 'by a reglar expression' do
        find('input#branch_name').set '^mas?er'
        click_on 'Filter'
        expect(all('tr.commit').size).to be >= 0
      end
    end

    describe 'by repositories ' do
      it 'by string' do
        expect(all('tr.commit').size).to be >= 1
        find('input#repository_name').set 'gabeldigoo'
        click_on 'Filter'
        expect(all('tr.commit').size).to be == 0
      end

      it 'by comma separated strings' do
        find('input#repository_name').set 'gabeldigoo, Demo Project'
        click_on 'Filter'
        expect(all('tr.commit').size).to be >= 1
      end

      it 'by a case insensitive reglar expression' do
        find('input#repository_name').set '^dem.+project'
        click_on 'Filter'
        expect(all('tr.commit').size).to be >= 1
      end
    end

    it 'by depth and pagination' do
      find('input#branch_name').set TEST_BRANCH
      find('select#depth').select('Heads only')
      click_on 'Filter'
      expect(page).to have_content "0 #{TEST_BRANCH}"
      expect(page).not_to have_content "1 #{TEST_BRANCH}"

      find('input#branch_name').set TEST_BRANCH
      find('select#depth').select('Max 1 down')
      click_on 'Filter'
      expect(page).to have_content "0 #{TEST_BRANCH}"
      expect(page).to have_content "1 #{TEST_BRANCH}"
      expect(page).not_to have_content "2 #{TEST_BRANCH}"

      find('input#branch_name').set TEST_BRANCH
      find('select#depth').select('Max 3 down')
      click_on 'Filter'
      expect(page).to have_content "0 #{TEST_BRANCH}"
      expect(page).to have_content "3 #{TEST_BRANCH}"
      expect(page).not_to have_content "4 #{TEST_BRANCH}"

      find('input#branch_name').set TEST_BRANCH
      find('select#depth').select('Any depth')
      find('select#per_page').select('3 Per page')
      click_on 'Filter'
      expect(page).to have_content "0 #{TEST_BRANCH}"
      expect(page).to have_content "2 #{TEST_BRANCH}"
      expect(page).not_to have_content "3 #{TEST_BRANCH}"

      find('input#branch_name').set TEST_BRANCH
      find('select#depth').select('Any depth')
      find('select#per_page').select('12 Per page')
      click_on 'Filter'
      expect(page).to have_content "0 #{TEST_BRANCH}"
      expect(page).to have_content "4 #{TEST_BRANCH}"
      expect(page).to have_content "5 #{TEST_BRANCH}"
      expect(page).to have_content "11 #{TEST_BRANCH}"
    end
  end
end
