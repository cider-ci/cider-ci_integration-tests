module Helpers
  module Users
    def self.create_users
      Helpers::ConfigurationManagement.invoke_ruby \
        'User.find_or_create_by(login: "admin", is_admin: true)' \
        '.update_attributes!(password: "secret",' \
        ' name: "Adam Ambassador",' \
        ' reload_frequency: "aggressive")'
      Helpers::ConfigurationManagement.invoke_ruby \
        'User.find_or_create_by(login: "normin")' \
        '.update_attributes!(password: "secret",' \
        ' name: "Normin Normalo",'\
        ' reload_frequency: "aggressive")'
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
