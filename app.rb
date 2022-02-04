require 'sinatra'
require 'pg'

set :port, 8080



# this function returns a string to be added to the postgresql search query constructed from user options
# it takes one parameter, the name of a particular postgres column
# it constructs part of a postgresql query that will compare the value of the POST'd parameter with a matching hash key
def compare (table_name)
    result_string = ''
    result_string.concat(table_name)
    result_string.concat(' ~* ')
    result_string.concat("'" + params[table_name] + "' AND ")
    return result_string
end



# this function manipulates the 'params' hash based on the state of the given parameter key
# if the given parameter key's value matches an empty string, delete the corresponding toggle record
# for the params color1, color2, hha_concept1, and hha_concept2, pass 'color' and 'hha_concept' respectively
def validate_param (value)
    if value == 'color'
        if params['color1'] == "" && params['color2'] == ""
            params.delete('t_' + value)
        end
    elsif value == 'hha_concept'
        if params['hha_concept1'] == "" && params['hha_concept2'] == ""
            params.delete('t_' + value)
        end
    elsif params[value] == ""
        params.delete('t_' + value)
    end
end



# this function returns a string which can then be passed to postgresql, and is constructed from user search terms
# it takes one parameter, the table name to select items from, and returns one query acting on that table
# intended to be used in a loop, particularly when search terms have been specified but not the table name
# general algorithm:
#  1. check if any of the options are ticked, if not, goto #6
#  2. go through each of the options and check if they are ticked individually
#  3. if an option is ticked, check if its corresponding value is '', if so, ignore it and move on to the next
#  4. append psql query option + 'AND' to `query` for the search filter section that has a usable value
#  5. remove trailing 'AND' from search_string
#  6. append ';' to search_string
#  7. done
def construct_query (kind)
    query = 'SELECT * FROM ' + kind + ' '
    any_selected = params['t_name'] || params['t_hha_concept'] || params['t_hha_series'] || params['t_size'] || params['t_hha_set'] || params['t_surface'] || params['t_hha_category'] || params['t_color'] || params['t_sort_points']

    if !any_selected
        query.concat(';')
        return query
    else
        query.concat('WHERE ')
        if params['t_name'] && params['name'] != '' && params['name'] != nil
            # need to do input validation for this condition
            query.concat(compare("name"))
        end
        if params['t_hha_concept'] && ( params['hha_concept1'] != '' || params['hha_concept2'] != '' )
            if params['hha_concept1'] != ''
                query.concat(compare("hha_concept1"))
            end

            if params['hha_concept2'] != ''
                query.concat(compare("hha_concept2"))
            end
        end
        if params['t_hha_series'] && params['hha_series'] != ''
            query.concat(compare("hha_series"))
        end
        if params['t_size'] && params['size'] != ''
            query.concat(compare("size"))
        end
        if params['t_hha_set'] && params['hha_set'] != ''
            query.concat(compare("hha_set"))
        end
        if params['t_surface'] && params['surface'] != ''
            params['surface'] = "Yes"
            query.concat(compare("surface"))
        end 
        if params['t_hha_category'] && params['hha_category'] != ''
            query.concat(compare("hha_category"))
        end
        if params['t_color'] && ( params['color1'] != '' || params['color2'] != '' )
            if params['color1'] != ''
                query.concat(compare("color1"))
            end
            if params['color2'] != ''
                query.concat(compare("color2"))
            end
        end
        query.chomp!(' AND ')
        return query
    end
end



# begin server response instructions

get '/' do
    redirect '/index.html'
end

get '/search' do
    data = "initial_state"

    begin
        connection = PG.connect :dbname => 'acnh_hha_app', :user => 'janna'
        erb :item, :layout => :search, :locals => {:data => data}

    rescue PG::Error => e
        data = "error"
        erb :item, :layout => :search, :locals => {:data => data}

    ensure
        connection.close if connection

    end
end

post '/search' do
    data = []
    total_results = []
    item_kinds = ['accessories', 'artwork', 'bags', 'bottoms', 'ceiling_decor', 'clothing_other', 'dress_up', 'fish', 'floors', 'fossils', 'gyroids', 'headwear', 'housewares', 'insects', 'interior_structures', 'miscellaneous', 'music', 'photos', 'posters', 'rugs', 'sea_creatures', 'shoes', 'socks', 'tools_goods', 'tops', 'umbrellas', 'wall_mounted', 'wallpaper']
    filters = ['name', 'hha_concept', 'kind', 'hha_series', 'size', 'hha_set', 'surface', 'hha_category', 'color', 'sort_points']

    begin
        connection = PG.connect :dbname => 'acnh_hha_app', :user => 'janna'
        
        filters.each do |filter|
            validate_param filter
        end

        # 'any' is a misnomer, t_kind is treated differently because of its unique effect on search_string
        any_selected = params['t_name'] || params['t_hha_concept'] || params['t_hha_series'] || params['t_size'] || params['t_hha_set'] || params['t_surface'] || params['t_hha_category'] || params['t_color'] || params['t_sort_points']

        if params['t_kind'] || any_selected
            query = ""
            query_results = []
            if params['t_kind']
                query = construct_query params['kind']
                
            else
                item_kinds.each do |kind|
                    query.concat(construct_query kind)
                    query.concat(" UNION ")
                end
                
                query.chomp!("UNION ")
            end

            query.concat(";")
            puts query
            query_results = connection.exec query
            query_results.each do |item|
                data.push(item)
            end
        else
            data = "no_selection"
        end

        erb :item, :layout => :search, :locals => {:data => data}
    
    rescue PG::Error => e
        data = "error"
        erb :item, :layout => :search, :locals => {:data => data}

    ensure
        connection.close if connection

    end
end