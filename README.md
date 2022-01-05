# acnh_hha_app

see: https://girljaro.systems:4444/index.php/category/development/acnh-hha-app/

## To Do
* write code for doing the db query with the received fields
* make search page not provide any data unless a query is entered
* display query results to user correctly
* update item result entries with more information
    * also update the css to make the information appear pretty
    * need to decide how to display items with multiple variations, and if items without multiple variations should appear the same way or not
* create option for each item displayed in search results to add it to the list of user furniture
    * might need ajax for this? :(
    * the user's list could be stored as a cookie and updated when the list is changed, but that could result in a very large cookie, and also would mean that logged users might not have their lists saved
    * is there a way to write to a database upon action from a user that doesn't involve js?
* do input validation for the one text box
* create bones for the myhouse page, prototype can just be displaying the list of activated items from search results

## Ideas
* populate the select boxes for search terms with erb db query that finds all possible colors/concepts/sets/categories/sizes? 
    * this would make the runtime for each operation much longer, maybe just do this every now and then?
    * how to make two yield statements on a single view respectively yield to the correct 'erb' calls?
    * 'yield' is only necessary for calling a different view -- erb code in the html itself will be interpreted as expected
* add an additional input field to 'color' and 'concept' that lets the user choose between 'and' and 'or' operations between color1 and color2 and concept1 and concept2 respectively