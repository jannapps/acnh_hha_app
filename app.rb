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



# begin server response instructions

get '/' do
    redirect '/index.html'
end

get '/search' do
    data = "initial_state"
    erb :item, :layout => :search, :locals => {:data => data}
end

post '/search' do
    data = []
    results = []
    search_string = 'SELECT * FROM '

    begin
        connection = PG.connect :dbname => 'acnh_hha_app', :user => 'janna'
        
        # general algorithm for this section: ( assuming base search_string is set up  (including 'kind' value))
        #  1. check if any of the options are ticked, if not, goto #6
        #  2. go through each of the options and check if they are ticked individually
        #  3. if an option is ticked, check if its corresponding value is '', if so, goto #5
        #  4. append psql query option + 'AND' to search_string for the search filter section that has a usable value
        #  5. remove trailing 'AND' from search_string
        #  6. append ';' to search_string
        #  7. done

        validate_param 'name'
        validate_param 'hha_concept'
        validate_param 'kind'
        validate_param 'hha_series'
        validate_param 'size'
        validate_param 'hha_set'
        validate_param 'surface'
        validate_param 'hha_category'
        validate_param 'color'
        validate_param 'sort_points'

        # 'any' is a misnomer, t_kind is treated differently because of its unique effect on search_string
        any_selected = params['t_name'] || params['t_hha_concept'] || params['t_hha_series'] || params['t_size'] || params['t_hha_set'] || params['t_surface'] || params['t_hha_category'] || params['t_color'] || params['t_sort_points']

        if !params['t_kind'] && !any_selected
            data = "no_selection"
        elsif any_selected
            if params['t_kind']
                search_string.concat(params['kind'] + ' ')
            else
                # need code for combining output from all tables to go here (logically, at least)
            end

            # temporary default table value for when 'kind' is left unselected
            search_string.concat('housewares' + ' ')
            # remove this later

            search_string.concat('WHERE ')
            if params['t_name'] && params['name'] != '' && params['name'] != nil
                # need to do input validation for this condition
                search_string.concat(compare("name"))
            end

            if params['t_hha_concept'] && ( params['hha_concept1'] != '' || params['hha_concept2'] != '' )
                if params['hha_concept1'] != ''
                    search_string.concat(compare("hha_concept1"))
                end

                if params['hha_concept2'] != ''
                    search_string.concat(compare("hha_concept2"))
                end
            end
            
            if params['t_hha_series'] && params['hha_series'] != ''
                search_string.concat(compare("hha_series"))
            end
            
            if params['t_size'] && params['size'] != ''
                search_string.concat(compare("size"))
            end

            if params['t_hha_set'] && params['hha_set'] != ''
                search_string.concat(compare("hha_set"))
            end

            if params['t_surface'] && params['surface'] != ''
                search_string.concat(compare("surface"))
            end
                
            if params['t_hha_category'] && params['hha_category'] != ''
                search_string.concat(compare("hha_category"))
            end
            
            if params['t_color'] && ( params['color1'] != '' || params['color2'] != '' )
                if params['color1'] != ''
                    search_string.concat(compare("color1"))
                end

                if params['color2'] != ''
                    search_string.concat(compare("color2"))
                end
            end

            if params['t_sort_points'] && params['sort_points'] != ''
                # this condition isn't like the others, use psql 'ORDER BY'
            end

            search_string.chomp!(' AND ')
            search_string.concat(';')
        
            # the following output appears in the rerun interactive session, useful for debugging
            puts search_string

            results = connection.exec search_string

            results.each do |item|
                data.push(item)
            end
        end

        erb :item, :layout => :search, :locals => {:data => data}
    end
end