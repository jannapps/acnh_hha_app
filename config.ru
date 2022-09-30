require './config/environment'

# use rackup to begin execution here
# this file just tells rack about the various controllers and gives it an entry point

use Rack::MethodOverride
use SearchController
use UserController
use ListController
run ApplicationController
