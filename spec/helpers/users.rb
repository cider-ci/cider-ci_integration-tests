module Helpers
  module Users
    def self.create_users
      Helpers::ConfigurationManagement.invoke_ruby \
        'User.find_or_create_by(login: "admin", is_admin: true)' \
        '.update_attributes!(password: "secret")'
      Helpers::ConfigurationManagement.invoke_ruby \
        'User.find_or_create_by(login: "normin")' \
        '.update_attributes!(password: "secret")'
    end

    def sign_in_as(login, password = 'secret')
      visit '/'
      sign_out if find('body')['data-user'].present?
      find("input[type='text']").set login
      find("input[type='password']").set password
      find("button[type='submit']").click
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
