require "addressable/uri"
require 'sinatra'
require 'pry'
require 'JSON'
require 'active_support/all'

CLIENT_ID = 'the-client-id'
CLIENT_SECRET = 'the-client-secret'
CODE = 'the-code'


USERS = {
  adam: {
    login: 'adam',
    id: 1,
    email: 'adam.admin@bogus.com',
    access_token: 'the-access-token-for-adam',
    emails: [
      {email: 'adam.admin@example.com',
       verified: true}
    ]
  },
  normin: {
    login: 'adam',
    id: 1,
    email: 'adam.admin@bogus.com',
    access_token: 'the-access-token-for-normin',
    emails: [
    ]
  }}.with_indifferent_access


USER = USERS[(ENV['GITHUB_MOCK_USER'].presence || 'adam')]


CALLBACK_URL = "http://localhost:" \
   << (ENV['REVERSE_PROXY_HTTP_PORT'].presence || '8888') \
   << '/cider-ci/ui/public/auth_provider/github/sign_in'


get '/login/oauth/authorize' do
  halt(422, "No such client") unless params[:client_id] == CLIENT_ID
  uri = Addressable::URI.parse(CALLBACK_URL)
  uri.query_values = {state: params[:state], code: CODE}
  redirect(uri.to_s , 303)
end

post '/login/oauth/access_token' do
  halt(403, "CODE missmatch") unless params[:code] == CODE
  halt(403, "CLIENT_ID missmatch") unless params[:client_id] == CLIENT_ID
  halt(403, "CLIENT_SECRET missmatch") unless params[:client_secret] == CLIENT_SECRET
  content_type 'application/json'
  {access_token: USER['access_token']}.to_json
end

get '/user' do
  unless user = find_user_by_access_token(params[:access_token])
    halt(404,"")
  else
    content_type 'application/json'
    user.slice(:login,:id,:email).to_json
  end
end

get '/user/emails' do
  unless user = find_user_by_access_token(params[:access_token])
    halt(404,"")
  else
    content_type 'application/json'
    user[:emails].to_json
  end
end

get '/users/:user' do
  unless user = USERS[params[:user]]
    halt(404,"User not found")
    unless user['access_token'] == params[:access_token]
      halt(403, "Wrong Access Token")
    else
      content_type 'application/json'
      user.slice(:login,:id,:email).to_json
    end
  end
end


def find_user_by_access_token access_token
  USERS.find{|k,v| v['access_token'] == access_token }.try(:second)
end
