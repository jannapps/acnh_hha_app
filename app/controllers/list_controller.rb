require './config/environment'

class ListController < ApplicationController

    # this function is where score calculation takes place
    # this is called each time an item is added to a room
    def calculate_score(room_id, room_score)
        begin
            connection = PG.connect :dbname => 'acnh_hha_app', :user => 'janna'

            @user = User.find_by(:uid => session[:uid])

            # get list of items in the room
            data = []
            query = "SELECT items.* FROM rooms INNER JOIN items ON rooms.filename = items.filename WHERE rooms.room_id = '" + room_id.to_s +  "';"
            query_results = connection.exec query
            query_results.each do |item|
                data.push(item)
            end

            # begin score calculation for this room
            score = 0
            item_quantity = 0
            wall_mounted = 0
            series = {}
            set = {}
            category = {}
            color = {}

            # count occurences of colors, categories, series, etc.
            data.each do |item|
                item_quantity += 1
                score += item['hha_base'].to_i
                
                if item['kind'] == 'Wall-mounted'
                    wall_mounted += 1
                end
                
                if series[item['hha_series']] == nil
                    series[item['hha_series']] = 1
                else
                    series[item['hha_series']] += 1
                end

                if set[item['hha_set']] == nil
                    set[item['hha_set']] = 1
                else
                    set[item['hha_set']] += 1
                end

                if category[item['hha_category']] == nil
                    category[item['hha_category']] = 1
                else
                    category[item['hha_category']] += 1
                end

                if color[item['color1']] == nil
                    color[item['color1']] = 1
                else
                    color[item['color1']] += 1
                end
                if color[item['color2']] == nil
                    color[item['color2']] = 1
                else
                    color[item['color2']] += 1
                end
            end

            # assign point bonuses based on coordination
            if item_quantity >= 6
                score += 1000
            end
            if item_quantity >= 10
                score += 1000
            end
            if item_quantity >= 15
                score += 1000
            end
            if item_quantity >= 20
                score += 1000
            end

            if wall_mounted < 3
                score += wall_mounted * 400
            else
                score += 400 * 3
            end

            series.each do |key, value|
                if value >= 4 && key != "None"
                    score += value * 1000
                end
            end

            category.each do |key, value|
                if value >= 3
                    score += value * 500
                end
            end

            color.each do |key, value|
                if value / item_quantity > 0.69
                    score += value * 200
                elsif value / item_quantity > 0.89
                    score += value * 600
                end
            end


            # update scores in database
            query = "UPDATE users SET " + room_score + " = '" + score.to_s + "' WHERE uid = '" + @user.uid + "';"
            query_results = connection.exec query

            @user = nil
            @user = User.find_by(:uid => session[:uid])

            total_score = 0
            total_score += @user.r1_score
            total_score += @user.r2_score
            total_score += @user.r3_score
            total_score += @user.r4_score
            total_score += @user.r5_score
            total_score += @user.r6_score

            query = "UPDATE users SET total_score = '" + total_score.to_s + "' WHERE uid = '" + @user.uid + "';"
            query_results = connection.exec query
        rescue PG::Error => e
            status 500
            body "Error updating score"
            puts "Error updating score"
        ensure
            connection.close if connection
        end
    end



    # handle route for list management
    # this route has no GET equivalent because it is only called by AJAX in item.erb
    # determines fields necessary to be added to the database, then adds them
    # this route handles insertion into rooms, wishlists, and collections
    post '/lists' do
        if session[:uid] == nil
            status 422
            body 'Not signed in'
        end

        @user = User.find_by(:uid => session[:uid])

        # determine the ID of the room desired
        case params['room']
        when 'r1'
            room_id = @user.r1_id
            room_score = "r1_score"
        when 'r2'
            room_id = @user.r2_id
            room_score = "r2_score"
        when 'r3'
            room_id = @user.r3_id
            room_score = "r3_score"
        when 'r4'
            room_id = @user.r4_id
            room_score = "r4_score"
        when 'r5'
            room_id = @user.r5_id
            room_score = "r5_score"
        when 'r6'
            room_id = @user.r6_id
            room_score = "r6_score"
        when 'wishlists'
            room_id = 'wishlists'
        when 'collections'
            room_id = 'collections'
        else
            puts "Error: params['room'] == " + params['room']
        end

        # handle insertion
        begin
            connection = PG.connect :dbname => 'acnh_hha_app', :user => 'janna'
            
            if room_id == 'wishlists'
                query = "INSERT INTO wishlists (uid, filename) VALUES ('" + session[:uid] + "', '" + params['filename'] + "');"
            elsif room_id == 'collections'
                query = "INSERT INTO collections (uid, filename) VALUES ('" + session[:uid] + "', '" + params['filename'] + "');"
            else
                query = "INSERT INTO rooms (uid, room_id, filename) VALUES ('" + session[:uid] + "', '" + room_id.to_s + "', '" + params['filename'] + "');"
            end

            query_results = connection.exec query

            # if a room insertion occured, calculate the new score
            # also, insert that item into collections too
            if room_id != 'wishlists' && room_id != 'collections'
                calculate_score(room_id, room_score)
                query = "INSERT INTO collections (uid, filename) VALUES ('" + session[:uid] + "', '" + params['filename'] + "');"
                query_results = connection.exec query
            end
        rescue PG::Error => e
            status 500
            body "Some insertion issue occured"
        ensure
            connection.close if connection
        end
    end



    # route for house summary
    # just displays some data by rendering erb
    get '/myhouse' do
        if session[:uid] == nil
            redirect '/login'
        end

        @user = User.find_by(:uid => session[:uid])

       erb :house
    end



    # route for individual room displays
    get '/myhouse/:room' do
        if session[:uid] == nil
            redirect '/login'
        end

        @user = User.find_by(:uid => session[:uid])
        room_id = nil
        data = nil

        # find score and name associated with this particular room
        case params[:room]
        when 'r1', 'r2', 'r3', 'r4', 'r5', 'r6'
            case params[:room]
            when 'r1'
                params[:room_long] = "Main Room"
                params[:room_points] = @user.r1_score
                room_id = @user.r1_id
            when 'r2'
                params[:room_long] = "West Room"
                params[:room_points] = @user.r2_score
                room_id = @user.r2_id
            when 'r3'
                params[:room_long] = "Back Room"
                params[:room_points] = @user.r3_score
                room_id = @user.r3_id
            when 'r4'
                params[:room_long] = "East Room"
                params[:room_points] = @user.r4_score
                room_id = @user.r4_id
            when 'r5'
                params[:room_long] = "Top Floor"
                params[:room_points] = @user.r5_score
                room_id = @user.r5_id
            when 'r6'
                params[:room_long] = "Basement"
                params[:room_points] = @user.r6_score
                room_id = @user.r6_id
            end

            # handle data retrieval
            begin
                connection = PG.connect :dbname => 'acnh_hha_app', :user => 'janna'
                query = "SELECT items.* FROM rooms INNER JOIN items ON rooms.filename = items.filename WHERE rooms.room_id = '" + room_id.to_s +  "';"
                data = []
                query_results = connection.exec query
                query_results.each do |item|
                    data.push(item)
                end
            rescue
                status 500
                body "Some retrieval error occured"
            ensure
                connection.close if connection
            end

            erb :item, :layout => :list, :locals => {:data => data}
        else
            status 404
            body "That's not a room!"
        end
    end

    

    # route for wishlist display
    get '/wishlist' do
        if session[:uid] == nil
            redirect '/login'
        end

        params[:room_long] = 'Wishlist'
        data = nil

        # handle data retrieval
        begin
            connection = PG.connect :dbname => 'acnh_hha_app', :user => 'janna'
            query = "SELECT items.* FROM wishlists INNER JOIN items ON wishlists.filename = items.filename WHERE wishlists.uid = '" + session[:uid] +  "';"
            data = []
            query_results = connection.exec query
            query_results.each do |item|
                data.push(item)
            end
        rescue
            status 500
            body "Some retrieval error occured"
        ensure
            connection.close if connection
        end

        erb :item, :layout => :list, :locals => {:data => data}
    end



    # route for collection display
    get '/collection' do
        if session[:uid] == nil
            redirect '/login'
        end

        params[:room_long] = 'Collection'
        data = nil

        # handle data retrieval
        begin
            connection = PG.connect :dbname => 'acnh_hha_app', :user => 'janna'
            query = "SELECT items.* FROM collections INNER JOIN items ON collections.filename = items.filename WHERE collections.uid = '" + session[:uid] +  "';"
            data = []
            query_results = connection.exec query
            query_results.each do |item|
                data.push(item)
            end
        rescue
            status 500
            body "Some retrieval error occured"
        ensure
            connection.close if connection
        end
        
        erb :item, :layout => :list, :locals => {:data => data}
    end

end