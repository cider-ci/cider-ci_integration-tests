module Helpers
  module Users
    def self.create_users

      FactoryBot.create(:admin,
                        login: 'admin',
                        is_admin: true,
                        password: 'secret',
                        reload_frequency: 'aggressive',)

      FactoryBot.create(:user,
                        login: 'normin',
                        name: 'Normin Normalo',
                        is_admin: false,
                        password: 'secret',
                        reload_frequency: 'aggressive')

    end

    def sign_in_as(login, password = 'secret')
      visit '/cider-ci/session/password/sign-in'
      find("form input#login").set login
      find("form input#password").set password
      click_on "Sign me in"
    end

    def set_aggressive_reloading
      find('#user-actions').click
      click_on('Session')
      find('select#reload_frequency').select('Aggressive')
      click_on('Save')
      visit '/'
    end

    def set_reloading(val)
      find('#user-actions').click
      click_on('Session')
      find('select#reload_frequency').select(val)
      click_on('Save')
      visit '/'
    end

    def sign_out
      find('#user-actions').click
      click_on 'Sign out'
    end
  end
end
