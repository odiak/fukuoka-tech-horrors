# coding: utf-8

require 'bundler'
Bundler.require

require 'sinatra/json'
require './settings'

class User < ActiveRecord::Base
  has_many :stories

  def serialize(**options)
    {
      id: id,
      uid: uid,
      screen_name: screen_name,
      name: name,
    }
  end
end

class Story < ActiveRecord::Base
  belongs_to :author, foreign_key: :author_id, class_name: :User

  validates :title, presence: true
  validates :body, presence: true
  validates :author, presence: true

  def serialize(**options)
    {
      id: id,
      title: title,
      body: body,
      author: author.serialize(**options),
      votes_count: votes_count,
      created_at: created_at,
      updated_at: updated_at,
    }
  end
end

configure do
  set :app_file, __FILE__
  set :database, adapter: 'sqlite3', database: 'database.sqlite3'

  disable :sessions
  use Rack::Session::Cookie,
    key: 'rack.session',
    expire_after: 20.days,
    secret: SESSION_SECRET

  use OmniAuth::Builder do
    provider :twitter, API_KEY, API_SECRET
  end

  use Rack::Parser, content_types: {
    'application/json' => ->(body) {::MultiJSON.decode(body)}
  }
end

helpers do
  def current_user
    session[:current_user]
  end

  def signed_in?
    !!current_user
  end

  def ensure_signed_in!
    halt 401 unless signed_in?
  end
end

get '/login' do
  redirect '/auth/twitter'
end

get '/logout' do
  session[:current_user] = nil

  redirect '/'
end

get '/auth/twitter/callback' do
  auth = env['omniauth.auth']
  user = User.find_or_initialize_by(uid: auth[:uid])
  user.screen_name = auth[:info][:nickname]
  user.name = auth[:info][:name]
  user.access_token = auth[:credentials][:token]
  user.access_token_secret = auth[:credentials][:secret]
  user.icon = auth[:info][:image]

  if user.save
    session[:current_user] = user
    redirect '/'
  else
    'error'
  end
end

get '/auth/failure' do
  'auth failure'
end

get '/api/user' do
  json current_user.serialize
end

post '/api/stories' do
  ensure_signed_in!

  story = Story.new(author: current_user)
  p params
  story.title = params['title']
  story.body = params['body']

  if story.save
    json story.serialize
  else
    status 422
    json error: story.errors.to_a.first
  end
end

get '/api/stories/recent' do
  limit = (params['limit'] || 10).to_i
  offset = params['limit'].to_i
  stories = Story.order(created_at: :desc).limit(limit).offset(offset)

  json stories: stories.map(&:serialize)
end

get '/api/stories/top' do
  limit = (params['limit'] || 10).to_i
  offset = params['limit'].to_i
  stories = Story.order(votes_count: :desc).limit(limit).offset(offset)

  json stories: stories.map(&:serialize)
end

get '/api/stories/:id' do
  story = Story.find_by(id: params['id'])
  halt 404 unless story

  json story.serialize
end

put '/api/stories/:id' do
  ensure_signed_in!

  story = Story.find_by(id: params['id'])
  halt 404 unless story
  halt 403 if story.author != current_user

  story.title = params['title']
  story.body = params['body']

  if story.save
    json story.serialize
  else
    status 422
    json error: story.errors.to_a.first
  end
end

post '/api/stories/:id/vote' do
end


# only for development
if settings.development?
  not_found do
    return if %r'^/(?:api|js|css|tpls)/?' =~ request.path_info
    status 200
    File.read("#{File.dirname(__FILE__)}/public/index.html")
  end
end
