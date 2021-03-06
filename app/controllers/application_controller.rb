require './config/environment'
class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, ENV['SESSION_SECRET']
  end

  get "/" do
    erb :welcome
  end

  helpers do
    
    def logged_in?
      !!current_user
    end
    
    def login(username, password)
      user = User.find_by(:username => username)
      if user && user.authenticate(password)
        session[:user_id] = user.id
        redirect to '/'
      else
        redirect to '/'
    end
  end
  
  def redirect_if_not_logged_in
    if !logged_in?
      redirect "/login"
    end
  end

  def logout!
      if session[:user_id] != nil
        session.destroy
        redirect to '/login'
      else
        redirect to '/'
    end
  end
  def current_user
     @current_user ||= User.find_by(:id => session[:user_id]) if session[:user_id]
    end
  end
    
  def get_data(name)
    url = "https://api.jikan.moe/v3/search/anime?q=#{name}&limit=5"
    #get data from jikan api for editing
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    response.body
  end
  
  def edit_data(name)
    animes = []
    #edit it down to desired information and save it
    data = JSON.parse(self.get_data(name))
    results = data.fetch("results")
    results.each do |result|
    animes <<  Anime.new(:mal_id => result["mal_id"], :title => result["title"], :rated => result["rated"], :synopsis => result["synopsis"], :url => result["url"], :score => result["score"], :image_url => result["image_url"],:airing=> result["airing"], :episodes => result["episodes"])
    end
      animes
  end


    def redirect_if_not_found
      redirect_if_not_logged_in
      @anime = Anime.find_by(id: params[:id], user_id: current_user.id)
      if !@anime
        redirect '/'
      end
    end
end
