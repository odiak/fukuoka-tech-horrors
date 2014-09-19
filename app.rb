# coding: utf-8

require 'bundler'
Bundler.require

require 'sinatra/json'
require './settings'

class User < ActiveRecord::Base
  has_many :stories

  def as_json(**options)
    {
      id: id,
      uid: uid,
      screen_name: screen_name,
      name: name,
      icon: icon,
    }
  end
end

class Story < ActiveRecord::Base
  belongs_to :author, foreign_key: :author_id, class_name: :User

  validates :title, presence: true
  validates :body, presence: true
  validates :author, presence: true

  def as_json(myself: nil, **options)
    {
      id: id,
      title: title,
      body: body,
      author: author.as_json(**options),
      votes_count: votes_count,
      created_at: created_at,
      updated_at: updated_at,
      voted: myself ? Voting.exists?(user_id: myself.id, story_id: id) : nil,
    }
  end
end

class Voting < ActiveRecord::Base
  belongs_to :user
  belongs_to :story

# private

#   def increment_votes_count
#     return unless story
#     Story.increment_counter(:votes_count, story_id)
#   end

#   def decrement_voting_count
#     return unless story
#     Story.decrement_counter(:votes_count, story_id)
#   end
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

get '/api/current_user' do
  if signed_in?
    json current_user
  else
    status 404
  end
end

post '/api/stories' do
  ensure_signed_in!

  story = Story.new(author: current_user)
  p params
  story.title = params['title']
  story.body = params['body']

  if story.save
    json story.as_json(myself: current_user)
  else
    status 422
    json error: story.errors.to_a.first
  end
end

get '/api/stories/recent' do
  limit = (params['limit'] || 10).to_i
  offset = params['offset'].to_i
  stories = Story
    .order(created_at: :desc)
    .limit(limit)
    .offset(offset)
    .includes(:author)

  json stories: stories.as_json(myself: current_user)
end

get '/api/stories/top' do
  limit = (params['limit'] || 10).to_i
  offset = params['offset'].to_i
  stories = Story
    .where.not(votes_count: 0)
    .order(votes_count: :desc, created_at: :asc)
    .limit(limit)
    .offset(offset)
    .includes(:author)

  json stories: stories.as_json(myself: current_user)
end

get '/api/stories/:id' do
  story = Story.find_by(id: params['id'])
  halt 404 unless story

  json story.as_json(myself: current_user)
end

put '/api/stories/:id' do
  ensure_signed_in!

  story = Story.find_by(id: params['id'])
  halt 404 unless story
  halt 403 if story.author != current_user

  story.title = params['title']
  story.body = params['body']

  if story.save
    json story.as_json(myself: current_user)
  else
    status 422
    json error: story.errors.to_a.first
  end
end

put '/api/stories/:id/vote' do
  story_id = params[:id]
  voting = Voting.find_by(user_id: current_user.id, story_id: story_id)
  increment = false
  if voting
    if voting.count < 10
      Voting.increment_counter(:count, voting.id)
      increment = true
    end
  else
    Voting.create(user_id: current_user.id, story_id: story_id)
    increment = true
  end

  if increment
    Story.increment_counter(:votes_count, story_id)
    json voted: true
  else
    json voted: false
  end
end

# only for development
if settings.development?
  not_found do
    return if %r'^/(?:api|js|css|tpls)/?' =~ request.path_info
    status 200
    File.read("#{File.dirname(__FILE__)}/public/index.html")
  end
end
