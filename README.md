# Animal Crossing: New Horizons HHA Score Calculator
# Catchy Title: ACNH-HHAC


## Important: To-Do List
* prevent search filter options with certain characters from breaking search
* use js to automatically tick the box for any filter that's being adjusted
    * also make sure the same options as the last search are already entered into the search filters when the page is reloaded
    * implement "clear search terms" button!
* use better fonts, sans-serif
* add some color to stuff, maybe just directly rip the red color from nookazon?
* copyright banner at the bottom of the screens?
* "go to top" button on search result page
* search result pagination to prevent dos-ing the CDN that hosts the icons
* need input validation


## Backlog: Ideas
* use models for items, lists, etc. instead of using raw SQL queries as is standard for rack mvc structure apps
* populate the select boxes for search terms with erb db query that finds all possible colors/concepts/sets/categories/sizes? 
    * this would make the runtime for each operation much longer, maybe just do this every now and then?
        * look into timing-based server-side commands for sinatra, maybe just use cron
    * how to make two yield statements on a single view respectively yield to the correct `erb` calls?
    * `yield` is only necessary for calling a different view -- erb code in the html itself will be interpreted as expected
        * sinatra only allows rendering one view per erb call! this means `yield` can only be called once in a controller
* add an additional input field to `color` and `concept` that lets the user choose between 'and' and 'or' operations between color1 and color2 and concept1 and concept2 respectively
* change "My House" hover menu to a click-and-open menu as is standard for web apps


## Notes
* 'build_query' is a function name already in-use here: `Rack::Utils::build_query(query)`
* doing a query for each table returned a postgres failure when that table didn't have the relevant column, e.g. searching by `surface` in the table `floors`, because the `surface` field isn't relevant in that case so there was no existing column
    * there is no efficient way to check if a column exists in postgres, and it is also not efficient to do a try/catch for each query (assuming it will fail in those cases)
    * this was resolved by creating those irrelevant columns in the tables affected by this issue, and just leaving their values NULL, now each table has columns equivalent to the `housewares` table
