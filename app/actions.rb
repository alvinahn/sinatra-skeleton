# Homepage (Root path)
require 'pry'
enable :sessions

get '/' do
  @tracks = Track.all
  if session["user"] != nil
    @user = User.find(session["user"])
  end
  erb :'tracks/index'
end

get '/tracks' do
  @tracks = Track.all
  erb :'tracks/index'
end

get '/tracks/new' do
  erb :'tracks/new'
end

post '/tracks' do
  @track = Track.new(
    title: params[:title],
    author: params[:author],
    url: params[:url],
    user_id: session["user"]
    )
  if @track.save
    redirect '/tracks'
  else
    erb :'tracks/new'
  end
end

get '/tracks/:id' do
  @track = Track.find params[:id]
  erb :'tracks/show'
end

get '/users/signup' do
  erb :'users/signup'
end

post '/users/signup' do
  @user = User.new(
    email: params[:email],
    password: params[:password]
    )
  if @user.save
    redirect '/'
  else
    erb :'users/signup'
  end
end

get '/users/signin' do
  # user_email=params[:email]
  @user = User.find_by(
    email: params[:email],
    password: params[:password]
    )
  if @user != nil
    session["user"] = @user.id
    session["email"] = @user.email
    redirect '/'
  else
    erb :'users/signin'
  end
end

get '/users/signout' do
  # session["user"] = nil
  session.clear
  redirect '/'
end

def first_vote?
  Vote.find_by(track_id: params[:id], user_id: session["user"]) == nil
end

def duplicated_vote?
  @vote.user_id == session["user"]
end

get '/tracks/vote/:id' do
  if session["user"] != nil
    if first_vote?
      @vote = Vote.new(
        user_id: session["user"]
        )
      @track1 = Track.find params[:id]
      @vote.track = @track1
      @vote.vote_count += 1
      @vote.track.vote_count += 1
      @vote.save
      @track1.save
    else
      @vote = Vote.new(
        track_id: params[:id],
        user_id: session["user"]
        )
      if duplicated_vote?
        puts "you are a duplicated voter"
      else
        @vote.vote_count += 1
        @vote.track.vote_count += 1
        @vote.save
        @vote.track.save
      end
    end
  end
  @tracks = Track.all
  erb :'/tracks/index'
end
