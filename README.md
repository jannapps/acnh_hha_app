# acnh_hha_app

see: https://girljaro.systems:4444/index.php/category/development/acnh-hha-app/

## To Do
* create css for search filter box
* create button that submits search filter box inputs with POST
* write code for doing the db query with the received fields
* create empty default option for all search terms that will leave that term unused in the query
* create option for each item displayed in search results to add it to the list of user furniture
  * might need ajax for this? :(
* do input validation for the one text box
* create bones for the myhouse page, prototype can just be displaying the list of activated items from search results

## Ideas
* populate the select boxes for search terms with erb db query that finds all possible colors/concepts/sets/categories/sizes? 
  * this would make the runtime for each operation much longer, maybe just do this every now and then?
  * how to make two yield statements on a single view respectively yield to the correct 'erb' calls?