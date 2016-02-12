require "addressable/uri"
require 'sinatra'
require 'pry'
require 'json'
require 'active_support/all'
require 'haml'

CLIENT_ID = 'the-client-id'
CLIENT_SECRET = 'the-client-secret'


USERS = {
  adam: {
    login: 'adam',
    id: 1,
    email: 'adam.admin@bogus.com',
    access_token: 'the-access-token-for-adam',
    name: "Adam Admin",
    emails: [
      {email: 'adam.admin@example.com',
       verified: true}
    ]
  },
  normin: {
    login: 'normin',
    id: 2,
    email: 'normin.normalo@bogus.com',
    name: "Normin Normalo",
    access_token: 'the-access-token-for-normin',
    emails: [
    ]
  },
  silvan: {
    login: 'silvan',
    id: 3,
    email: 'silvan.stranger@bogus.com',
    name: "Silvan Strange",
    access_token: 'the-access-token-for-silvan',
    emails: [
    ]
  }}.with_indifferent_access

ORGS = {
  "TestOrg": [:normin]
}

USER = USERS[(ENV['GITHUB_MOCK_USER'].presence || 'adam')]


CALLBACK_URL = "http://localhost:" \
   << (ENV['REVERSE_PROXY_HTTP_PORT'].presence || '8888') \
   << '/cider-ci/ui/public/auth_provider/github/sign_in'


get '/login/oauth/authorize' do
  halt(422, "No such client") unless params[:client_id] == CLIENT_ID


  html= USERS.map do |k,v|
    Haml::Engine.new(
      <<-HAML.strip_heredoc
      %form{method: 'POST'}
        %input{type: 'hidden', name: 'login', value: '#{v[:login]}'}
        %button{type: 'submit'}
          Sign in as #{v[:login]}
      %hr
      HAML
      ).render
  end.join("\n")

  html
end

post '/login/oauth/authorize' do
  uri = Addressable::URI.parse(CALLBACK_URL)
  uri.query_values = {state: params[:state], code: params[:login]}
  redirect(uri.to_s , 303)
end


post '/login/oauth/access_token' do
  halt(403, "CODE missmatch") unless USERS[params[:code]]
  halt(403, "CLIENT_ID missmatch") unless params[:client_id] == CLIENT_ID
  halt(403, "CLIENT_SECRET missmatch") unless params[:client_secret] == CLIENT_SECRET
  content_type 'application/json'
  {access_token: USERS[params[:code]]['access_token']}.to_json
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

get '/orgs/TestOrg/members/normin' do
  halt(204,"")
end


def find_user_by_access_token access_token
  USERS.find{|k,v| v['access_token'] == access_token }.try(:second)
end
