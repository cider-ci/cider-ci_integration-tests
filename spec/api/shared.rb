require 'spec_helper'

def api_base_url
  "#{Capybara.app_host}/cider-ci/api/"
end

def json_roa_client(&block)
  JSON_ROA::Client.connect \
    api_base_url, raise_error: false, &block
end

def authenticated_json_roa_client
  json_roa_client do |conn|
    conn.basic_auth('admin', 'secret')
  end
end
