require './config/environment'

class UserController < ApplicationController

    # handle registration display route
    # registration isn't possible if you're already signed-in
    get '/register' do
        if signed_in?
            redirect '/profile'
        else
            erb :register
        end
    end
    
    

    # handle registration submit route
    # does a very basic check to make sure all fields are provided
    # uid collision checking is performed in the user model
    post '/register' do
        if params[:username].empty? || params[:password].empty?
            redirect '/register'
        else
            begin
                @all_users = User.all
                user_num = @all_users.length()
                offset = user_num * 6
            rescue
                user_num = 0
                offset = user_num
            end
            @user = User.create(:uid => params[:username], :pass => params[:password], :total_score => 0, 
                                :r1_id => offset + 1, :r1_score => 0,
                                :r2_id => offset + 2, :r2_score => 0,
                                :r3_id => offset + 3, :r3_score => 0,
                                :r4_id => offset + 4, :r4_score => 0,
                                :r5_id => offset + 5, :r5_score => 0,
                                :r6_id => offset + 6, :r6_score => 0)
            
            session[:uid] = @user.uid
            redirect '/profile'
        end
    end
    


    # handle login display route
    # login isn't possible if you're already signed-in
    get '/login' do
        if signed_in?
          redirect '/profile'
        else
          erb :login
        end
    end
    
    

    # handle login submit route
    # does a simple check for uid and pass matching db entries
    # the bcrypt gem could be used to handle password checking & would make password storage secure
    # this would require a password_digest key in the user schema
    post '/login' do
        @user = User.find_by(:uid => params[:username])
        # should probably use bcrypt to do this and actually use @user.authenticate lol
        if @user && @user.pass == params[:password]
            session[:uid] = @user.uid
            redirect '/profile'
        else
            redirect '/register'
        end
    end
    
    

    # handle profile route
    # just renders some erb if you're signed-in
    get '/profile' do
        if signed_in?
            erb :profile
        else
            redirect '/login'
        end
    end

    

    # handle logout route
    # destroys the session and redirects if you're signed-in
    get '/logout' do
        if signed_in?
            session.destroy
            redirect '/login'
        else
            redirect '/index.html'
        end
    end

end
