require 'rest-client'

module Helpers
  module SystemAdmin
    class << self

      def connection
        base_url = "#{Capybara.app_host}/cider-ci/"
        conn = Faraday.new(base_url) do |conn|
          conn.adapter Faraday.default_adapter
          conn.headers['Content-Type'] = 'application/json'
          conn.headers['Authorization'] = 'token master-secret'
          conn.response :json
        end

        conn_test_respo = conn.get "authenticated-entity"

        raise 'system-admin connection failed' \
          unless  conn_test_respo.status == 200
        raise 'system-admin authentication failed' \
          unless (conn_test_respo.body['authenticated-entity']['type'] \
                  == "system-admin")
        conn
      end

    end
  end
end
