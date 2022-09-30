require './config/environment'

class SearchController < ApplicationController
    
    # define a few functions for assisting with search
    # a model could be created to handle items instead of passing raw sql to postgres instead of this
    # this methodology was chosen because it more cleanly fits the project requirements



    # this horrible, horrible function creates several arrays which represent all possible choices for search filters
    # once arrays are defined, they are placed into a global dictionary for easy iteration in search.erb
    # this is here so I didn't have to type out every single option in HTML myself
    def define_fields()
        concepts = [
            "amusement park",
            "ancient",
            "apparel shop",
            "arcade",
            "bathroom",
            "café",
            "child's room",
            "city life",
            "concert",
            "construction site",
            "den",
            "European",
            "expensive",
            "facility",
            "fancy",
            "fantasy",
            "fitness",
            "freezing cold",
            "garden",
            "harmonious",
            "heritage",
            "horror",
            "hospital",
            "kitchen",
            "lab",
            "living room",
            "local",
            "music",
            "nature",
            "None",
            "ocean",
            "office",
            "outdoors",
            "park",
            "party",
            "public bath",
            "resort",
            "restaurant",
            "retro",
            "school",
            "shop",
            "space",
            "sports",
            "stylish",
            "supermarket",
            "workshop"
        ]

        kinds = [
            "Accessories",
            "Bags",
            "Bottoms",
            "Ceiling_decor",
            "Clothing_Other",
            "Fish",
            "Floors",
            "Fossils",
            "Gyroids",
            "Headwear",
            "Housewares",
            "Insects",
            "Interior_structures",
            "Miscellaneous",
            "Rugs",
            "Sea_creatures",
            "Shoes",
            "Socks",
            "Tops",
            "Walls"
        ]

        colors = [
            "Aqua",
            "Beige",
            "Black",
            "Blue",
            "Brown",
            "Colorful",
            "Gray",
            "Green",
            "None",
            "Orange",
            "Pink",
            "Purple",
            "Red",
            "White",
            "Yellow"
        ]

        categories = [
            "AC",
            "Appliance",
            "Audio",
            "Clock",
            "Doll",
            "Dresser",
            "Food",
            "Kitchen",
            "Lighting",
            "MusicalInstrument",
            "None",
            "Pet",
            "Plant",
            "SmallGoods",
            "Trash",
            "TV"
        ]

        sizes = [
            "0.5x0.5",
            "0.5x1",
            "1.5x1.5",
            "1x0.5",
            "1x1",
            "1x1.5",
            "1x2",
            "2x0.5",
            "2x1",
            "2x1.5",
            "2x2",
            "3x1",
            "3x2",
            "3x3",
            "4x3",
            "4x4",
            "5x5"
        ]

        series = [
            "antique",
            "bamboo",
            "Bunny Day",
            "cardboard",
            "cherry blossoms",
            "Cinnamoroll",
            "cool",
            "cute",
            "diner",
            "dreamy",
            "elegant",
            "Festivale",
            "festive",
            "flowers",
            "frozen",
            "fruits",
            "golden",
            "Hello Kitty",
            "imperial",
            "iron",
            "ironwood",
            "Kerokerokeroppi",
            "Kiki & Lala",
            "log",
            "Mario",
            "mermaid",
            "Moroccan",
            "motherly",
            "mush",
            "My Melody",
            "None",
            "Nordic",
            "patchwork",
            "pirate",
            "plaza",
            "Pompompurin",
            "ranch",
            "rattan",
            "shell",
            "simple",
            "sloppy",
            "spooky",
            "stars",
            "throwback",
            "tree's bounty or leaves",
            "Turkey Day",
            "vintage",
            "wedding",
            "wooden",
            "wooden block"
        ]

        sets = [
            "apple",
            "artsy",
            "bear",
            "birthday",
            "bug head",
            "castle",
            "chalkboard",
            "cherry",
            "den",
            "gaming",
            "garden",
            "imperial dining",
            "iron garden",
            "kitchen",
            "lecture hall",
            "metal and wood",
            "natural",
            "None",
            "office",
            "orange",
            "panda",
            "peach",
            "pear",
            "pet",
            "ruined",
            "school",
            "sports ring",
            "standee",
            "stone",
            "study"
        ]

        @fields = {'concepts' => concepts, 'kinds' => kinds, 'colors' => colors,
                  'categories' => categories, 'sizes' => sizes, 'series' => series, 'sets' => sets}
    end


    
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
    def construct_query ()
        query = 'SELECT * FROM items '
        any_selected = params['t_kind'] || params['t_name'] || params['t_hha_concept'] || params['t_hha_series'] || params['t_size'] || params['t_hha_set'] || params['t_surface'] || params['t_hha_category'] || params['t_color']

        if !any_selected
            return query
        else
            query.concat('WHERE ')
            if params['t_kind'] && params['kind'] != '' && params['kind'] != nil
                query.concat(compare("kind"))
            end
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



    # start handling routes here


    # handle route for searching
    # this displays the search page as well as handling various errors
    get '/search' do
        data = "initial_state"

        define_fields

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
    
    

    # handle route for search queries
    # this takes the submitted parameters and uses them (along with above functions) to build an sql query
    # this could be done without a POST -- but this is easier
    post '/search' do
        data = []
        total_results = []
        item_kinds = ['accessories', 'artwork', 'bags', 'bottoms', 'ceiling_decor', 'clothing_other', 'dress_up', 'fish', 'floors', 'fossils', 'gyroids', 'headwear', 'housewares', 'insects', 'interior_structures', 'miscellaneous', 'music', 'photos', 'posters', 'rugs', 'sea_creatures', 'shoes', 'socks', 'tools_goods', 'tops', 'umbrellas', 'wall_mounted', 'wallpaper']
        filters = ['name', 'hha_concept', 'kind', 'hha_series', 'size', 'hha_set', 'surface', 'hha_category', 'color', 'sort_points']
    
        define_fields

        begin
            connection = PG.connect :dbname => 'acnh_hha_app', :user => 'janna'
            
            filters.each do |filter|
                validate_param filter
            end
    
            any_selected = params['t_kind'] || params['t_sort_points'] || params['t_name'] || params['t_hha_concept'] || params['t_hha_series'] || params['t_size'] || params['t_hha_set'] || params['t_surface'] || params['t_hha_category'] || params['t_color']
    
            if any_selected
                query = construct_query
                query_results = []
    
                if params['t_sort_points']
                    query.concat(" ORDER BY hha_base DESC ")
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
    
end