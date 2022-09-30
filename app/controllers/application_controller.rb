require './config/environment'

class ApplicationController < Sinatra::Base

    # perform environment configuration
    # active listening port should be set as an arg to rackup
    configure do
        set :public_folder, 'public'
        set :views, 'app/views'
        enable :sessions
        set :session_secret, "secret message :)"
    end



    # handle default route; just load the static html file
    # might change this so it renders erb if stuff should be displayed in the topbar dynamically
    get "/" do
        redirect "/index.html"
    end



    # handle user session management
    # this just "remembers" the user session info between pages
    helpers do
        def signed_in?
            !!current_user
        end

        def current_user
            @current_user ||= User.find_by(uid: session[:uid]) if session[:uid]
        end
    end
    
end
