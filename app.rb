# coding: utf-8

require "bundler"
Bundler.require

require "./settings"

class User < ActiveRecord::Base
end

class Story < ActiveRecord::Base
end

configure do
  set :app_file, __FILE__
  set :database, adapter: "sqlite3", database: "database.sqlite3"

  disable :sessions
  use Rack::Session::Cookie,
    key: "rack.session",
    expire_after: 20.days,
    secret: SESSION_SECRET

  use OmniAuth::Builder do
    provider :twitter, API_KEY, API_SECRET
  end
end

helpers do
  def current_user
    session[:current_user]
  end

  def signed_in?
    !!current_user
  end
end

get "/login" do
  redirect "/auth/twitter"
end

get "/logout" do
  session[:current_user] = nil

  redirect "/"
end

get "/auth/twitter/callback" do
  auth = env["omniauth.auth"]
  user = User.find_or_initialize_by(uid: auth[:uid])
  user.screen_name = auth[:info][:nickname]
  user.name = auth[:info][:name]
  user.access_token = auth[:credentials][:token]
  user.access_token_secret = auth[:credentials][:secret]
  user.icon = auth[:info][:image]

  if user.save
    session[:current_user] = user
    redirect "/"
  else
    "error"
  end
end

get "/auth/failure" do
  "auth failure"
end

get "/" do
  current_user.to_json
end
