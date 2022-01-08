# acnh_hha_app

see: https://girljaro.systems:4444/index.php/category/development/acnh-hha-app/

## To Do
* finish code for doing the db query with the received fields
* update item result css to make the all fields visible to the user
    * need to decide how to display items with multiple variations, and if items without multiple variations should appear the same way or not
    * see the mockup on goodnotes for more info
* create option for each item displayed in search results to add it to the list of user furniture (or to a room of their house)
    * might need ajax for this? :(
    * the user's list could be stored as a cookie and updated when the list is changed, but that could result in a very large cookie, and also would mean that logged users might not have their lists saved
    * is there a way to write to a database upon action from a user that doesn't involve js?
* do input validation for the one text box
    * this could be difficult, considering many item names contain the '-' character
* create bones for the myhouse page, prototype can just be displaying the list of activated items from search results
* implement a single room page where a user can add furniture to their room
    * display hha point sum value using formula
    * display statistics to the user about their furniture choices, probably just use the values calculated for the point formula and put them somewhere as they're calculated
* use js to automatically tick the box for any filter that's being adjusted
    * also make sure the same options as the last search are already entered into the search filters when the page is reloaded
    * implement "clear search terms" button!
* use better fonts, sans-serif
* add some color to stuff, maybe just directly rip the red color from nookazon?
* implement the copyright banner at the bottom of the screens
* implement "go to top" button on search result page
* change "My House" hover menu to a click-and-open menu as is standard for web apps

## Ideas
* populate the select boxes for search terms with erb db query that finds all possible colors/concepts/sets/categories/sizes? 
    * this would make the runtime for each operation much longer, maybe just do this every now and then?
        * look into timing-based server-side commands for sinatra, maybe just use cron
    * how to make two yield statements on a single view respectively yield to the correct `erb` calls?
    * `yield` is only necessary for calling a different view -- erb code in the html itself will be interpreted as expected
        * sinatra only allows rendering one view per erb call! this means `yield` can only be called once in a controller
* add an additional input field to `color` and `concept` that lets the user choose between 'and' and 'or' operations between color1 and color2 and concept1 and concept2 respectively
* `sort_points` is probably useless, why would anyone want lo-to-hi ordering?
    * it would make more sense to be a bool, where false=alphabetical and true=numerical sort

## Notes
* 'build_query' is a function name already in-use here: `Rack::Utils::build_query(query)`